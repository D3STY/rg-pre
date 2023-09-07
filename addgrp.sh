#!/bin/env bash

SECOND_GRP="STAFFPRE"

if [ $# -ne 3 ]; then
    echo "Usage: $0 <source file> <group> <pre_path>"
    exit 1
fi

SOURCE_FILE="$1"
GROUP="$2"
PRE_PATH="$3"
NEWLINE="privpath $PRE_PATH"
SEARCHSTR="$NEWLINE"

if [ "${NEWLINE: -1}" != "/" ]; then
    NEWLINE="$NEWLINE/"
fi

NEWLINE="$NEWLINE$GROUP=$GROUP                       =$SECOND_GRP"

already_written=0

while IFS= read -r line; do
    if [ $already_written -eq 0 ] && [[ "$line" == *"$SEARCHSTR"* ]]; then
        echo "$NEWLINE"
        already_written=1
    fi
    echo "$line"
done <"$SOURCE_FILE" >temp_file && mv temp_file "$SOURCE_FILE"

if [ $already_written -eq 1 ]; then
    echo "Successfully added the $GROUP dir to $SOURCE_FILE."
else
    echo "Couldn't find a place to add the $GROUP dir to $SOURCE_FILE."
    echo "Appending $GROUP to the end..."
    echo "$NEWLINE" >>"$SOURCE_FILE"
    echo "Successfully appended $GROUP as the first pre dir to $SOURCE_FILE."
fi

exit 0
