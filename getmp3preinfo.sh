#!/bin/bash
# Load pre.conf
pre_conf="$(dirname "$0")/pre.conf"
if [ -s "$pre_conf" ]; then
    . "$pre_conf" || {
        echo "[ERROR] could not load $pre_conf"
        exit 1
    }
fi

# Find and extract the output
fname=$(ls "$1"/*"$sitename"* | awk -F" - COMPLETE - " '{print $2}')
output=$(echo "$fname" | awk -F" ) - " '{print $1}' | tr -d '[:digit:]')
echo "$output"
