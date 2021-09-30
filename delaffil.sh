#!/bin/bash

declare -A loglevels=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
script_logging_level="INFO"
# Check if .conf file exist, source if it does
pre_conf="$(dirname "$0")/pre.conf"
if [ -s "$pre_conf" ]; then
	. "$pre_conf" || { echo "[ERROR] could not load $pre_conf"; exit 1; }
fi

log() {
	if [[ "${loglevels[$2]}" != "" && ${loglevels[$2]} -ge ${loglevels[$script_logging_level]} ]]; then
		echo "$(date '+%Y-%m-%d %H:%M:%S') [PRE] ${2}: DELAFFIL - ${1}"  >>"$logpath"/rg-pre.log
	fi
}

if [ $# -ge 1 ]; then
   if [ $# -eq 2 ]; then
      pre_path=$2
   else
      pre_path=$base_pre_path
   fi
      if [ "${pre_path:1:1}" != "/" ]; then
         pre_path="/site/$pre_path"
   echo "Removing $1 ..."
   echo "Trying to remove $pre_path/$1 from the $glftpd_conf file ..."
   log "Trying to remove $pre_path/$1 from the $glftpd_conf file ..." "INFO"
   lines_num=$(< "$glftpd_conf" wc -l)
   /bin/delaffil "$glftpd_conf" "$1" "$pre_path" "$lines_num"
   if [ -d "$pre_path/$1" ]; then
      rm -rf "${pre_path:?}/""$1"
      echo "Success! $pre_path/$1 has been removed."
      echo "Group $1 is NO LONGER affiled on this site!!!"
      log "Group $1 is NO LONGER affiled on $sitename and Group-dir was removed" "INFO"
   else
      echo "The $1 directory doesn't exist, there is no pre dir to remove."
      log "Group $1 directory already removed" "WARN"
      echo "Group $1 wasn't fully set or didn't exist, however it got fully removed now!"
   fi
else
   echo "Syntax: SITE DELAFFIL <group> [pre_dr_path]"
fi
fi