#!/bin/bash
pre_conf="$(dirname "$0")/pre.conf"
if [ -s "$pre_conf" ]; then
	. "$pre_conf" || { echo "[ERROR] could not load $pre_conf"; exit 1; }
fi

genre="Unknown"
cd "$1" || exit
for file in *.nfo; do
	if [ "$file" != "*.nfo" ]; then
		tempgenre=$(/bin/getmvpreinfo "$1" "$file")
		if [ $genre = "Unknown" ]; then
			genre=$tempgenre
		fi
	fi
done
touch "[$sitename] - ( $genre ) - [$sitename]"
echo "MVID - Genre: $genre"
