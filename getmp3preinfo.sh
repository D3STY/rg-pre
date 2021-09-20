#! /bin/bash
sitename="RG"
fname=$(ls "$1" \[$sitename\])

first=$(echo "$fname" | awk -F" - COMPLETE - " '{ print $1 }')
second=$(echo "$fname" | awk -F" - COMPLETE - " '{ print $2 }')
output=$(echo "$second" | awk -F" ) - " '{ print $1 }')
echo "$output"
