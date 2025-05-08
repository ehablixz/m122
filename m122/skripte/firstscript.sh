#!/bin/bash

echo "Das ist mein erstes Script"

if [[ ! -f $1 ]]; then
    echo "Datei existiert nicht"
    exit 1
fi

cat "$1" >> output.txt
cat output.txt
