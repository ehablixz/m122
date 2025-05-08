#!/bin/bash

# Author: Ajan Zuberi
# Description: Simple number guessing game. guess from 1-100
# Run using: ./numbergame.sh
# Options:
# none
# Parameters:
# none
# Version: 1.00
# Created on: 20.03.2025
#
# Changelog:
# 20.03.25 : Created Script (A.Z.)
#
# Settings / Variables
MINNUM=1
MAXNUM=100

# DO NOT CHANGE THE SCRIPT BELOW UNLESS YOU KNOW WHAT YOU ARE DOING



# Helper Functions
notnumeric() {
	[[ ! $1 =~ ^[0-9]+$ ]]
}



# Main script
echo "Welcome to my number guessing game!"

GUESS=-1
ATTEMPTS=0

echo -e "Change settings? [\e[32my\e[0m/\e[31mN\e[0m] default (N)"
read YESNO
case $YESNO in
	[yY])
		echo -en "Change minimum number: \e[33m"
		read NEWMINNUM
		((MINNUM=NEWMINNUM))
		echo -en "\e[0mChange maximum number: \e[33m"
		read NEWMAXNUM
		((MAXNUM=NEWMAXNUM))
		echo -e "\e[0mSettings updated for this session. If you want to permanently modify the settings, modify the script using an editor."
		;;
	*)
		echo "Keeping default settings"
		;;
esac

RANDOMNUM=$(( RANDOM % (MAXNUM - MINNUM + 1) + MINNUM ))

while true; do
	echo ""
	echo -en "Guess a number between \e[36m$MINNUM and $MAXNUM\e[0m: \e[33m"
	read GUESS
	((ATTEMPTS++))
	echo -en "\e[0m"
	if notnumeric "$GUESS"; then
		echo -e "\e[31mThat is not an integer number!\e[0m"
		continue
	fi

	if [[ $GUESS -lt $RANDOMNUM ]]; then
		echo -e "You guessed \e[31mtoo low!\e[0m"
	elif [[ $GUESS -gt $RANDOMNUM ]]; then
		echo -e "You guessed \e[31mtoo high!\e[0m"
	else
		echo -e "\e[32mCorrect in $ATTEMPTS attempts!"
		echo -e "You win.\e[0m"
		break
	fi
done



