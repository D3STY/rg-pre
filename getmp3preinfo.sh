#!/bin/bash
sitename=""
fname=$(ls "$1"/*$sitename*)

second=$(echo "$fname" | awk -F" - COMPLETE - " '{ print $2 }')
output=$(echo "$second" | awk -F" ) - " '{ print $1 }' | tr -d '[:digit:]')
echo "$output"
