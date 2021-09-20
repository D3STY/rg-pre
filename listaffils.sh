#! /bin/bash
glftpd_conf="/etc/glftpd.conf"

privpaths=$(< $glftpd_conf grep privpath | awk '{print $2}')

predirs=""
for path in $privpaths; do
	predirs="$predirs $(basename "$path")"
done
echo "$predirs"
exit 0
