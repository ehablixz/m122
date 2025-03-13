#!/bin/bash

# Author: Ajan Zuberi
# Description: Multiplies the first and second parameter
# Run using: ./script.sh
# Options:
# none
# Parameters:
# 1. First number
# 2. Second number
# Version: 1.00
# Created on: 13.03.2025
#
# Changelog:
# 13.03.25 : Created script (AZ)

# Settings / Variables
# none

# DO NOT CHANGE THE SCRIPT BELOW UNLESS YOU KNOW WHAT YOU ARE DOING

echo "Simple Bash Calc"
echo "Enter first number:"
read num1

echo "Enter operator (+, -, *, /):"
read op

echo "Enter second number:"
read num2

# Berechnung basierend auf dem Operator
case $op in
  +) result=$(echo "$num1 + $num2" | bc) ;;
  -) result=$(echo "$num1 - $num2" | bc) ;;
  \*) result=$(echo "$num1 * $num2" | bc) ;;  # * muss mit \ escaped werden
  /) result=$(echo "scale=2; $num1 / $num2" | bc) ;; # scale=2 für 2 Nachkommastellen
  *) echo "Invalid operator!" && exit 1 ;;
esac

echo "Result: $result"
