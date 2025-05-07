#!/bin/bash

# Author: Ajan Zuberi
# Description: Git auto-push script for automated repository management
# Run using: ./autogit.sh
# Options: none
# Parameters: none
# Version: 1.01
# Created on: 07.05.2025
#
# Changelog:
# 07.05.2025 : Created Script (A.Z.)
# 08.05.2025 : Added logging to file (A.Z.)
#
# Settings / Variables

# Configuration constants
CONFIG_FILE="$HOME/.config/autogit.conf"
AUTOGIT_CRON_SCRIPT="$HOME/bin/autogit-cron.sh"
DEFAULT_COMMIT_MESSAGE="Auto commit"
LOG_FILE="$HOME/.config/autogit.log"  # New log file location
BACKUP_DIR="$HOME/.config/autogit/backups"

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function definitions
log_info() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${GREEN}[INFO]${NC} $1"
    echo "[$timestamp] [INFO] $1" >> "$LOG_FILE"
}

log_warning() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${YELLOW}[WARNING]${NC} $1"
    echo "[$timestamp] [WARNING] $1" >> "$LOG_FILE"
}

log_error() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[$timestamp] [ERROR] $1" >> "$LOG_FILE"
}

# Function to initialize log file
init_log_file() {
    # Create the directory if it doesn't exist
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Create or truncate the log file if it's larger than 1MB to prevent unlimited growth
    if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt 1048576 ]; then
        # Keep the last 100 lines and overwrite the file
        tail -n 100 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
        log_info "Log file rotated due to size limit"
    fi
    
    # Add header to log file if it doesn't exist or was rotated
    if [ ! -s "$LOG_FILE" ]; then
        echo "===== AUTOGIT LOG =====" > "$LOG_FILE"
        echo "Started logging on $(date)" >> "$LOG_FILE"
        echo "=========================" >> "$LOG_FILE"
    fi
}

# New function to view logs
view_logs() {
    if [ ! -f "$LOG_FILE" ]; then
        log_error "No log file found at $LOG_FILE"
        read -p "Press Enter to return to menu..."
        return
    fi
    
    echo "Log file options:"
    echo "1) View entire log file"
    echo "2) View last 20 lines"
    echo "3) View errors only"
    echo "4) Clear log file"
    echo "5) Return to main menu"
    
    read -p "Please select an option [1-5]: " log_option
    
    case $log_option in
        1)
            if command -v less &> /dev/null; then
                less "$LOG_FILE"
            else
                cat "$LOG_FILE"
                read -p "Press Enter to continue..."
            fi
            ;;
        2)
            tail -n 20 "$LOG_FILE"
            read -p "Press Enter to continue..."
            ;;
        3)
            # NEW LOOP #4: Filter and display error logs
            echo "Errors from log file:"
            grep -n "\[ERROR\]" "$LOG_FILE" | while read -r line; do
                echo -e "${RED}$line${NC}"
            done
            read -p "Press Enter to continue..."
            ;;
        4)
            read -p "Are you sure you want to clear the log file? [y/N]: " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                init_log_file
                log_info "Log file cleared"
            fi
            ;;
        5)
            return
            ;;
        *)
            log_error "Invalid option."
            view_logs
            ;;
    esac
    
    show_menu
}

check_prerequisites() {
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        log_error "Git could not be found. Please install Git."
        exit 1
    fi
    
    # NEW LOOP #1: Check for additional recommended tools
    log_info "Checking for recommended tools..."
    declare -a tools=("git-lfs" "git-flow" "meld")
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            log_info "✓ $tool is installed"
        else
            log_warning "✗ $tool is not installed (optional)"
        fi
    done
}

create_config_file() {
    # Create the directory if it doesn't exist
    mkdir -p "$(dirname "$CONFIG_FILE")"
    
    log_info "No config file found. Creating default configuration..."
    
    cat <<EOF > "$CONFIG_FILE"
# Autogit Configuration File
# Created on: $(date +"%Y-%m-%d %H:%M:%S")

# Repository path (must be a valid git repository)
REPO_PATH="$(pwd)"

# Default commit message
COMMIT_MESSAGE="$DEFAULT_COMMIT_MESSAGE"

# Automatic push (yes/no)
AUTO_PUSH="no"
EOF
    
    chmod 644 "$CONFIG_FILE"
    log_info "Config file created at $CONFIG_FILE with default values."
}

# Modified create_cron_script to include logging
create_cron_script() {
    # Create the directory if it doesn't exist
    mkdir -p "$(dirname "$AUTOGIT_CRON_SCRIPT")"
    
    log_info "Creating autogit cron script..."
    
    cat <<EOF > "$AUTOGIT_CRON_SCRIPT"
#!/bin/bash

# Autogit automated script
# Created on: $(date +"%Y-%m-%d %H:%M:%S")

# Define log file
LOG_FILE="$LOG_FILE"
BACKUP_DIR="$BACKUP_DIR"

# Function to log messages
log_message() {
    local timestamp=\$(date "+%Y-%m-%d %H:%M:%S")
    echo "[\$timestamp] [CRON] \$1" >> "\$LOG_FILE"
    echo "\$1"
}

# Function to create backup
create_backup() {
    local repo_path="\$1"
    local repo_name=\$(basename "\$repo_path")
    local timestamp=\$(date +"%Y%m%d_%H%M%S")
    local backup_file="\${BACKUP_DIR}/\${repo_name}_\${timestamp}.tar.gz"
    
    # Create backup directory if it doesn't exist
    mkdir -p "\$BACKUP_DIR"
    
    log_message "Creating backup of repository: \$repo_path"
    
    # Fixed tar command
    # Navigate to the parent directory first, then create archive using relative path
    (cd "\$(dirname "\$repo_path")" && tar -czf "\$backup_file" \
        --exclude="\$(basename "\$repo_path")/.git/objects" \
        "\$(basename "\$repo_path")")
    
    if [ \$? -eq 0 ]; then
        log_message "Backup created successfully at \$backup_file"
        # Keep only the 5 most recent backups
        ls -t "\${BACKUP_DIR}/\${repo_name}_"*.tar.gz 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null
    else
        log_message "Backup creation failed"
    fi
}

# Source configuration if available
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Validate repository path
REPO_PATH=\${REPO_PATH:-\$(pwd)}
if [ ! -d "\$REPO_PATH/.git" ]; then
    log_message "Error: \$REPO_PATH is not a git repository."
    exit 1
fi

# Create backup before any operations
create_backup "\$REPO_PATH"

# Change to repository directory
cd "\$REPO_PATH" || exit 1
log_message "Working in repository at \$REPO_PATH"

# Perform git operations
log_message "Pulling latest changes..."
git pull >> "\$LOG_FILE" 2>&1

log_message "Adding modified files..."
git add . >> "\$LOG_FILE" 2>&1

# Use provided message or default
COMMIT_MSG=\${1:-"\$COMMIT_MESSAGE"}
log_message "Committing with message: \$COMMIT_MSG"
git commit -m "\$COMMIT_MSG" >> "\$LOG_FILE" 2>&1 || log_message "No changes to commit or commit failed"

# Push if auto-push is enabled or confirmed
if [ "\$AUTO_PUSH" = "yes" ]; then
    log_message "Pushing changes automatically..."
    git push >> "\$LOG_FILE" 2>&1 || log_message "Push failed"
    log_message "Automated git operations completed"
else
    log_message "Auto-push disabled. Changes committed but not pushed."
fi
EOF
    
    chmod +x "$AUTOGIT_CRON_SCRIPT"
    log_info "Created executable script at $AUTOGIT_CRON_SCRIPT with backup and logging capability"
}

edit_config() {
    if command -v nano &> /dev/null; then
        nano "$CONFIG_FILE"  # Remove sudo
    elif command -v vi &> /dev/null; then
        vi "$CONFIG_FILE"  # Remove sudo
    else
        log_error "No text editor found (nano or vi)."
        exit 1
    fi
}

setup_cron() {
    log_warning "You must know cronjob syntax to proceed!"
    echo "1) Edit using user privileges (recommended)"
    echo "2) Edit using root privileges (only if repo is in a protected dir)"
    echo "3) Return to main menu"
    
    read -p "Please select an option [1-3]: " cron_option
    
    case $cron_option in
        1)
            log_info "Editing cronjob using user privileges..."
            log_warning "Add a line like: 0 * * * * $AUTOGIT_CRON_SCRIPT"
            crontab -e
            ;;
        2)
            log_info "Editing cronjob using root privileges..."
            log_warning "Add a line like: 0 * * * * $AUTOGIT_CRON_SCRIPT"
            sudo crontab -e
            ;;
        3)
            return
            ;;
        *)
            log_error "Invalid option."
            setup_cron
            ;;
    esac
}

# New function to create a repository backup
create_repo_backup() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="${BACKUP_DIR}/${repo_name}_${timestamp}.tar.gz"
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    log_info "Creating backup of repository: $repo_path"
    log_info "Backup will be stored at: $backup_file"
    
    # Fixed tar command
    # Navigate to the parent directory first, then create archive using relative path
    (cd "$(dirname "$repo_path")" && tar -czf "$backup_file" \
        --exclude="$(basename "$repo_path")/.git/objects" \
        "$(basename "$repo_path")")
    
    if [ $? -eq 0 ]; then
        log_info "Backup created successfully"
        # Keep only the 5 most recent backups to prevent disk space issues
        ls -t "${BACKUP_DIR}/${repo_name}_"*.tar.gz 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null
        log_info "Cleaned up old backups, keeping 5 most recent"
    else
        log_error "Backup creation failed"
    fi
}

# Function to manage backups
manage_backups() {
    # Source config to get repository path
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
    
    # Validate repository path
    REPO_PATH=${REPO_PATH:-$(pwd)}
    
    if [ ! -d "$REPO_PATH/.git" ]; then
        log_error "The specified directory ($REPO_PATH) is not a git repository."
        read -p "Press Enter to return to menu..."
        return
    fi
    
    echo "Backup options:"
    echo "1) Create backup now"
    echo "2) List existing backups"
    echo "3) Restore from backup"
    echo "4) Return to main menu"
    
    read -p "Please select an option [1-4]: " backup_option
    
    case $backup_option in
        1)
            create_repo_backup "$REPO_PATH"
            read -p "Press Enter to continue..."
            ;;
        2)
            repo_name=$(basename "$REPO_PATH")
            echo "Available backups for $repo_name:"
            # NEW LOOP #5: List all available backups with details
            ls -l "${BACKUP_DIR}/${repo_name}_"*.tar.gz 2>/dev/null | while read -r line; do
                echo "$line" | awk '{print $6, $7, $8, $9}'
            done
            
            if [ $? -ne 0 ]; then
                log_error "No backups found for this repository"
            fi
            read -p "Press Enter to continue..."
            ;;
        3)
            repo_name=$(basename "$REPO_PATH")
            echo "Available backups for $repo_name:"
            
            # Create array of backup files
            mapfile -t backups < <(ls "${BACKUP_DIR}/${repo_name}_"*.tar.gz 2>/dev/null)
            
            if [ ${#backups[@]} -eq 0 ]; then
                log_error "No backups found for this repository"
                read -p "Press Enter to continue..."
                return
            fi
            
            # Display backup options
            for i in "${!backups[@]}"; do
                echo "$((i+1))) $(basename "${backups[$i]}")"
            done
            
            # Ask which backup to restore
            read -p "Select backup to restore [1-${#backups[@]}] or 0 to cancel: " backup_choice
            
            if [[ "$backup_choice" =~ ^[0-9]+$ ]] && [ "$backup_choice" -ge 1 ] && [ "$backup_choice" -le ${#backups[@]} ]; then
                selected_backup="${backups[$((backup_choice-1))]}"
                
                # Confirm restoration
                read -p "WARNING: This will overwrite current repository state! Continue? [y/N]: " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    log_warning "Restoring repository from backup: $(basename "$selected_backup")"
                    
                    # Create a temporary directory
                    TMP_DIR=$(mktemp -d)
                    
                    # Extract the backup to the temporary directory
                    tar -xzf "$selected_backup" -C "$TMP_DIR"
                    
                    # Get the repository directory name
                    REPO_DIR=$(find "$TMP_DIR" -maxdepth 1 -type d | tail -n 1)
                    
                    # Copy files to the current repository (preserving .git directory)
                    rsync -a --exclude=".git" "$REPO_DIR/" "$REPO_PATH/"
                    
                    # Clean up
                    rm -rf "$TMP_DIR"
                    
                    log_info "Repository restored successfully from backup"
                else
                    log_info "Restoration cancelled"
                fi
            elif [ "$backup_choice" -eq 0 ]; then
                log_info "Restoration cancelled"
            else
                log_error "Invalid selection"
            fi
            read -p "Press Enter to continue..."
            ;;
        4)
            return
            ;;
        *)
            log_error "Invalid option."
            manage_backups
            ;;
    esac
    
    show_menu
}

run_git_operations() {
    # Source config to get latest settings
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
    
    # Validate repository path
    REPO_PATH=${REPO_PATH:-$(pwd)}
    
    if [ ! -d "$REPO_PATH/.git" ]; then
        log_error "The specified directory ($REPO_PATH) is not a git repository."
        echo "Please enter a valid git repository path:"
        read -r new_path
        
        if [ ! -d "$new_path/.git" ]; then
            log_error "Invalid repository path. Exiting."
            exit 1
        fi
        
        # Update config with new path
        REPO_PATH="$new_path"
        sed -i "s|REPO_PATH=.*|REPO_PATH=\"$REPO_PATH\"|" "$CONFIG_FILE"
    fi
    
    # Create backup before any operations
    create_repo_backup "$REPO_PATH"
    
    # Change to repository directory
    cd "$REPO_PATH" || exit 1
    log_info "Working in repository at $REPO_PATH"
    
    # Git operations
    log_info "Pulling latest changes..."
    git pull
    
    log_info "Adding changes..."
    
    # NEW LOOP #2: Show status of modified files before adding
    log_info "Modified files:"
    git status -s | while read -r line; do
        status=${line:0:2}
        file=${line:3}
        
        case $status in
            "M "*)
                echo -e "${YELLOW}Modified:${NC} $file"
                ;;
            "A "*)
                echo -e "${GREEN}Added:${NC} $file"
                ;;
            "D "*)
                echo -e "${RED}Deleted:${NC} $file"
                ;;
            "R "*)
                echo -e "${YELLOW}Renamed:${NC} $file"
                ;;
            "??"*)
                echo -e "${GREEN}New file:${NC} $file"
                ;;
            *)
                echo -e "${YELLOW}Changed:${NC} $file"
                ;;
        esac
    done
    
    git add .
    
    echo "Enter your commit message:"
    read -p "> " COMMIT_MSG
    
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="$DEFAULT_COMMIT_MESSAGE"
        log_warning "Using default commit message: $COMMIT_MSG"
    fi
    
    log_info "Committing changes..."
    git commit -m "$COMMIT_MSG"
    
    echo "Confirm git push? [Y/n]:"
    read -p "> " CONFIRM
    
    if [[ "$CONFIRM" =~ ^[Yy]$ || -z "$CONFIRM" ]]; then
        log_info "Pushing changes to remote repository..."
        git push
        log_info "Git operations completed successfully."
    else
        log_warning "Changes committed but not pushed."
    fi
}

check_git_history() {
    # Source config to get latest settings
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
    
    # Validate repository path
    REPO_PATH=${REPO_PATH:-$(pwd)}
    
    if [ ! -d "$REPO_PATH/.git" ]; then
        log_error "The specified directory ($REPO_PATH) is not a git repository."
        return 1
    fi
    
    # Change to repository directory
    cd "$REPO_PATH" || return 1
    log_info "Checking commit history in repository at $REPO_PATH"
    
    # Ask how many commits to display
    read -p "How many recent commits would you like to see? [5]: " commit_count
    commit_count=${commit_count:-5}
    
    # LOOP #3: Display recent commits with details
    log_info "Last $commit_count commits:"
    git log -n "$commit_count" --pretty=format:"%h | %an | %ar | %s" | while IFS="|" read -r hash author time message; do
        echo -e "${YELLOW}$hash${NC} | ${GREEN}$author${NC} | $time | $message"
    done
    
    # Return to menu
    echo
    read -p "Press Enter to return to menu..."
    show_menu
}

# Update the show_menu function to include the log viewing option
show_menu() {
    clear
    echo "==============================================="
    echo "              AUTOGIT MANAGER                 "
    echo "==============================================="
    echo "1) Edit configuration file"
    echo "2) Setup automated cronjob"
    echo "3) Run git operations now"
    echo "4) View commit history"
    echo "5) View operation logs"  # New menu item
    echo "6) Manage backups"  # New menu item
    echo "7) Exit"
    echo "==============================================="
    
    read -p "Please select an option [1-7]: " option
    
    case $option in
        1)
            edit_config
            show_menu
            ;;
        2)
            setup_cron
            show_menu
            ;;
        3)
            run_git_operations
            show_menu
            ;;
        4)
            check_git_history
            ;;
        5)
            view_logs
            ;;
        6)
            manage_backups  # New function call
            ;;
        7)
            log_info "Exiting..."
            exit 0
            ;;
        *)
            log_error "Invalid option."
            show_menu
            ;;
    esac
}

# Main execution
# Initialize log file first
init_log_file
log_info "Starting autogit script"

check_prerequisites

# Check for config file and create if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    create_config_file
fi

# Check for cron script and create if it doesn't exist
if [ ! -f "$AUTOGIT_CRON_SCRIPT" ]; then
    create_cron_script
fi

# Display main menu
show_menu
