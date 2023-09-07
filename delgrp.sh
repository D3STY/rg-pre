#!/bin/env bash

SECOND_GRP="STAFFPRE"

if [ $# -ne 5 ]; then
    echo "Usage: $0 <source file> <group> <pre_path> <glftpd_conf_lines_num>"
    exit 1
fi

SOURCE_FILE="$1"
GROUP="$2"
PRE_PATH="$3"
NEWLINE="privpath $PRE_PATH"

if [ "${NEWLINE: -1}" != "/" ]; then
    NEWLINE="$NEWLINE/"
fi

NEWLINE="$NEWLINE$GROUP                       =$GROUP =$SECOND_GRP"

GLFTPD_CONF_LINES_NUM="$4"
ALREADY_WRITTEN=0

IFS=$'\n' read -d '' -r -a STORAGE < <(cat "$SOURCE_FILE")

for ((i = 0; i < ${#STORAGE[@]}; i++)); do
    line="${STORAGE[i]}"

    if [ $ALREADY_WRITTEN -eq 0 ] && [[ "$line" == *"$GROUP"* ]] && [[ "$line" == *"$NEWLINE"* ]] && [[ "$line" == *"$SECOND_GRP"* ]]; then
        i=$((i + 1))
        if [ $i -lt ${#STORAGE[@]} ]; then
            ALREADY_WRITTEN=1
            STORAGE[$i]="$NEWLINE"
        else
            ALREADY_WRITTEN=1
            break
        fi
    fi
done

if [ $ALREADY_WRITTEN -eq 1 ]; then
    printf "%s\n" "${STORAGE[@]}" >"$SOURCE_FILE"
    echo "The $SOURCE_FILE has been updated, group $GROUP has been removed from it."
else
    echo "The $SOURCE_FILE wasn't updated, group $GROUP wasn't found in it."
fi

exit 0
