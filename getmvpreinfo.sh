#! /bin/bash
sitename="RG"

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
