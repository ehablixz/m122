#!/bin/bash

# Author: Ajan Zuberi
# Description: Git auto-push script
# Run using: ./autogit.sh
# Options:
# none
# Parameters:
# none
# Version: 1.00
# Created on: 07.05.2025
#
# Changelog:
# 07.05.2025 : Created Script (A.Z.)
#
# Settings / Variables

# DO NOT CHANGE THE SCRIPT BELOW UNLESS YOU KNOW WHAT YOU ARE DOING
# Check if git is installed
if ! command -v git &> /dev/null
then
    echo "Git could not be found. Please install Git."
    exit 1
fi

# Check for a config file in /etc
if [ ! -f /etc/autogit.conf ]; then
    echo "No config file found in /etc. Creating autogit.conf with default values."
    COMMIT_MESSAGE="Auto commit"
    GIT_DIR="$(pwd)"
    echo "COMMIT_MESSAGE='$COMMIT_MESSAGE'" > /etc/autogit.conf
    echo "GIT_DIR='$GIT_DIR'" >> /etc/autogit.conf
    echo "Config file created at /etc/autogit.conf with default values."
else
    # Load config file
    source /etc/autogit.conf
    echo "Loaded config file from /etc/autogit.conf"
fi

# 1) Edit config file 2) Edit Cronjob 3) Run script 4) Exit
echo "1) Edit config file"
echo "2) Edit cronjob"
echo "3) Run script"
echo "4) Exit"
read -p "Please select an option: " option

case $option in
    1)
        echo "Editing config file..."
        nano /etc/autogit.conf
        ;;
    2)
        echo "You must know cronjob sytax to use this!!!"
        echo "1) Edit using user priveleges"
        echo "2) Edit using root priveleges"
        echo "3) Exit"
        read -p "Please select an option: " cron_option

        case $cron_option in
            1)
                echo "Editing cronjob using user privileges..."
                crontab -e
                ;;
            2)
                echo "Editing cronjob using root privileges..."
                sudo crontab -e
                ;;
            3)
                echo "Exiting..."
                ;;
        esac
        ;;
    3)
        echo "Running script..."
        # Check if the directory is a git repository
        if [ ! -d "$GIT_DIR/.git" ]; then
            echo "The specified directory is not a git repository."
            exit 1
        fi

    
