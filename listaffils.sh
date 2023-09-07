#!/bin/bash
# Check if .conf file exists and source it
pre_conf="$(dirname "$0")/pre.conf"
if [ -s "$pre_conf" ]; then
    source "$pre_conf" || {
        echo "[ERROR] could not load $pre_conf"
        exit 1
    }
fi

predirs=$(grep <"$glftpd_conf" privpath | awk '{print $2}' | xargs -n 1 basename)
echo "$predirs"
exit 0
