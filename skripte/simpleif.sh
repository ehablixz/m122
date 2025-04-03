#!/bin/bash

echo -n "Geben sie eine Zahl ein: "
read VAR

if [[ $VAR -gt 10 ]] then
	echo "Groesser als 10"
elif [[ $VAR -lt 10 ]] then
	echo "Kleiner als 10"
else
	echo "Gleich 10"
fi
