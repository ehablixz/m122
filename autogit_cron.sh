#!/bin/bash

# Colors (optional in cron, but okay for logs)
FG_BBLUE='\033[1;34m'
FG_BBLACK='\033[1;30m'
FG_BGREEN='\033[1;32m'
FG_BRED='\033[1;31m'
RESET='\033[0m'

# Default commit message and backup path
COMMIT_MESSAGE="Auto generated commit"
# Default backup folder path
BACKUP_FOLDER_PATH="/home/catgirl/BACKUP_m122/auto_backup"

# Create backup folder if it doesn't exist
mkdir -p "$BACKUP_FOLDER_PATH"
cd "/home/catgirl/m122" || exit 1
# Check if inside a git repo
if [ ! -d ".git" ]; then
    echo -e "${FG_BRED}Not a git repository. Exiting.${RESET}"
    exit 1
fi

# Check required commands
for cmd in git tar; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${FG_BRED}Command $cmd not found.${RESET}"
        exit 1
    fi
done

# Run git operations
echo -e "${FG_BGREEN}[$(date)] Pulling changes...${RESET}"
git pull

echo -e "${FG_BGREEN}[$(date)] Staging...${RESET}"
git add .

echo -e "${FG_BGREEN}[$(date)] Committing...${RESET}"
git commit -m "$COMMIT_MESSAGE"

echo -e "${FG_BGREEN}[$(date)] Pushing...${RESET}"
git push

# Create backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPO_NAME=$(basename "$(pwd)")
BACKUP_FILENAME="${REPO_NAME}_backup_${TIMESTAMP}.tar.gz"

tar --exclude="$BACKUP_FOLDER_PATH" -czf "/tmp/$BACKUP_FILENAME" .
mv "/tmp/$BACKUP_FILENAME" "$BACKUP_FOLDER_PATH"

echo -e "${FG_BBLUE}[$(date)] Backup done at: $BACKUP_FOLDER_PATH/$BACKUP_FILENAME${RESET}"
