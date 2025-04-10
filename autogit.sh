#!/bin/bash

# Author: Ajan Zuberi
# Description: Automatically update git repository and create a zip as a backup
# Run using: ./autogit.sh
# Options:
# Commit message
# Backup folder path
#
# Parameters:
# None
#
# Version: 1.00
# Created on: 10.04.2025
#
# Changelog:
# 10.04.25 : Skript erstellt (A.Z.)
#
# Settings / Variables

# source ./colors.sh # Load color definitions

# Reset
RESET="\e[0m"

# Standard Foreground Colors
FG_BLACK="\e[30m"
FG_RED="\e[31m"
FG_GREEN="\e[32m"
FG_YELLOW="\e[33m"
FG_BLUE="\e[34m"
FG_MAGENTA="\e[35m"
FG_CYAN="\e[36m"
FG_WHITE="\e[37m"

# Bright Foreground Colors
FG_BBLACK="\e[90m"    # Bright Black (Gray)
FG_BRED="\e[91m"
FG_BGREEN="\e[92m"
FG_BYELLOW="\e[93m"
FG_BBLUE="\e[94m"
FG_BMAGENTA="\e[95m"
FG_BCYAN="\e[96m"
FG_BWHITE="\e[97m"

# Standard Background Colors
BG_BLACK="\e[40m"
BG_RED="\e[41m"
BG_GREEN="\e[42m"
BG_YELLOW="\e[43m"
BG_BLUE="\e[44m"
BG_MAGENTA="\e[45m"
BG_CYAN="\e[46m"
BG_WHITE="\e[47m"

# Bright Background Colors
BG_BBLACK="\e[100m"
BG_BRED="\e[101m"
BG_BGREEN="\e[102m"
BG_BYELLOW="\e[103m"
BG_BBLUE="\e[104m"
BG_BMAGENTA="\e[105m"
BG_BCYAN="\e[106m"
BG_BWHITE="\e[107m"

# DO NOT CHANGE THE SCRIPT BELOW UNLESS YOU KNOW WHAT YOU ARE DOING


#!/bin/bash

# Colors for output
FG_BBLUE='\033[1;34m'
FG_BBLACK='\033[1;30m'
FG_BGREEN='\033[1;32m'
FG_BRED='\033[1;31m'
RESET='\033[0m'

echo -e "${FG_BBLUE}Welcome to autogit.sh"
echo -e "${FG_BBLACK}This script automates git commands and creates a tar.gz backup of the repository.${RESET}"

echo "Please enter the commit message (Default: \"Auto generated commit\"):"
read COMMIT_MESSAGE 
echo -e "You entered: ${FG_BBLUE}$COMMIT_MESSAGE${RESET}"
if [ -z "$COMMIT_MESSAGE" ]; then
    COMMIT_MESSAGE="Auto generated commit"
    echo -e "No commit message provided. Using default: ${FG_BBLUE}$COMMIT_MESSAGE${RESET}"
fi

echo "Please enter the backup folder path (Default /home/${USER}/BACKUP_m122):"
read BACKUP_FOLDER_PATH
echo -e "You entered: ${FG_BBLUE}$BACKUP_FOLDER_PATH${RESET}"

if [ -z "$BACKUP_FOLDER_PATH" ]; then
    BACKUP_FOLDER_PATH="/home/$USER/BACKUP_m122"
    echo -e "No backup folder path provided. Using default: ${FG_BBLUE}$BACKUP_FOLDER_PATH${RESET}"
fi

# Check and create backup folder if needed
if [ ! -d "$BACKUP_FOLDER_PATH" ]; then
    echo -e "${FG_BGREEN}Creating backup folder at $BACKUP_FOLDER_PATH${RESET}"
    mkdir -p "$BACKUP_FOLDER_PATH"
fi

# Check if this is a git repo
if [ ! -d ".git" ]; then
    echo -e "${FG_BRED}This script must be run inside a git repository.${RESET}"
    exit 1
fi

# Check for required commands
for cmd in git tar; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${FG_BRED}Required command '$cmd' not found. Please install it.${RESET}"
        exit 1
    fi
done

# Run git pull to sync with remote
echo -e "${FG_BGREEN}Pulling latest changes from remote...${RESET}"
git pull

# Stage changes
echo -e "${FG_BGREEN}Staging all changes...${RESET}"
git add .

# Commit
echo -e "${FG_BGREEN}Committing with message: '$COMMIT_MESSAGE'${RESET}"
git commit -m "$COMMIT_MESSAGE"

# Push
echo -e "${FG_BGREEN}Pushing to remote...${RESET}"
git push

# Create backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPO_NAME=$(basename "$(pwd)")
BACKUP_FILENAME="${REPO_NAME}_backup_${TIMESTAMP}.tar.gz"

echo -e "${FG_BGREEN}Creating tar.gz backup...${RESET}"
tar --exclude="$BACKUP_FOLDER_PATH" -czf "/tmp/$BACKUP_FILENAME" .

echo -e "${FG_BGREEN}Moving backup to: ${BACKUP_FOLDER_PATH}${RESET}"
mv "/tmp/$BACKUP_FILENAME" "$BACKUP_FOLDER_PATH"

echo -e "${FG_BBLUE}All done! Backup created at: ${BACKUP_FOLDER_PATH}/${BACKUP_FILENAME}${RESET}"
