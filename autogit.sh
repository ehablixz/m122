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
# 08.05.2025 : Fixed structure and improved error handling (A.Z.)
#
# Settings / Variables

# Configuration constants
CONFIG_FILE="$HOME/.config/autogit.conf"
AUTOGIT_CRON_SCRIPT="$HOME/bin/autogit-cron.sh"
DEFAULT_COMMIT_MESSAGE="Auto commit"

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function definitions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        log_error "Git could not be found. Please install Git."
        exit 1
    fi
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

create_cron_script() {
    # Create the directory if it doesn't exist
    mkdir -p "$(dirname "$AUTOGIT_CRON_SCRIPT")"
    
    log_info "Creating autogit cron script..."
    
    cat <<EOF > "$AUTOGIT_CRON_SCRIPT"
#!/bin/bash

# Autogit automated script
# Created on: $(date +"%Y-%m-%d %H:%M:%S")

# Source configuration if available
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Validate repository path
REPO_PATH=\${REPO_PATH:-\$(pwd)}
if [ ! -d "\$REPO_PATH/.git" ]; then
    echo "Error: \$REPO_PATH is not a git repository."
    exit 1
fi

# Change to repository directory
cd "\$REPO_PATH" || exit 1

# Perform git operations
echo "Pulling latest changes..."
git pull

echo "Adding modified files..."
git add .

# Use provided message or default
COMMIT_MSG=\${1:-"\$COMMIT_MESSAGE"}
echo "Committing with message: \$COMMIT_MSG"
git commit -m "\$COMMIT_MSG"

# Push if auto-push is enabled or confirmed
if [ "\$AUTO_PUSH" = "yes" ]; then
    echo "Pushing changes automatically..."
    git push
else
    read -p "Push changes? [Y/n]: " CONFIRM
    if [[ "\$CONFIRM" =~ ^[Yy]$ || -z "\$CONFIRM" ]]; then
        git push
    else
        echo "Changes committed but not pushed."
    fi
fi
EOF
    
    chmod +x "$AUTOGIT_CRON_SCRIPT"
    log_info "Created executable script at $AUTOGIT_CRON_SCRIPT"
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
    
    # Change to repository directory
    cd "$REPO_PATH" || exit 1
    log_info "Working in repository at $REPO_PATH"
    
    # Git operations
    log_info "Pulling latest changes..."
    git pull
    
    log_info "Adding changes..."
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

show_menu() {
    clear
    echo "==============================================="
    echo "              AUTOGIT MANAGER                 "
    echo "==============================================="
    echo "1) Edit configuration file"
    echo "2) Setup automated cronjob"
    echo "3) Run git operations now"
    echo "4) Exit"
    echo "==============================================="
    
    read -p "Please select an option [1-4]: " option
    
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
            ;;
        4)
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
