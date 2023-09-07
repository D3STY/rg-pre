#!/bin/bash
# Check if .conf file exist, source if it does
pre_conf="$(dirname "$0")/pre.conf"
if [ -s "$pre_conf" ]; then
    . "$pre_conf" || {
        echo "[ERROR] could not load $pre_conf"
        exit 1
    }
fi

privpaths=$(grep <"$glftpd_conf" privpath | awk '{print $2}')

predirs=""
for path in $privpaths; do
    predirs="$predirs $(basename "$path")"
done
echo "$predirs"
exit 0
