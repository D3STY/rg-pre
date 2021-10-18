#!/bin/bash
pre_conf="$(dirname "$0")/pre.conf"
if [ -s "$pre_conf" ]; then
	. "$pre_conf" || {
		echo "[ERROR] could not load $pre_conf"
		exit 1
	}
fi
fname=$(ls "$1"/*"$sitename"*)

second=$(echo "$fname" | awk -F" - COMPLETE - " '{ print $2 }')
output=$(echo "$second" | awk -F" ) - " '{ print $1 }' | tr -d '[:digit:]')
echo "$output"
