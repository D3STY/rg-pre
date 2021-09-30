#!/bin/bash
# Check if .conf file exist, source if it does
pre_conf="$(dirname "$0")/pre.conf"
if [ -s "$pre_conf" ]; then
# shellcheck source=pre.conf
	. "$pre_conf" || { echo "[ERROR] could not load $pre_conf"; exit 1; }
fi

declare -A loglevels=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
script_logging_level="INFO"
log() {
	if [[ "${loglevels[$2]}" != "" && ${loglevels[$2]} -ge ${loglevels[$script_logging_level]} ]]; then
		echo "$(date '+%Y-%m-%d %H:%M:%S') [PRE] ${2}: ADDAFFIL - ${1}"  >>"$logpath"/rg-pre.log
	fi
}


if [ $# -ge 1 ]; then
	if [ $# -eq 2 ]; then
		pre_path=$2
	else
		pre_path=$base_pre_path
	fi
	if [ "${pre_path:1:5}" != "/site" ]; then
		if [ "${pre_path:1:1}" != "/" ]; then
			pre_path="/site/$pre_path"
		else
			pre_path="/site$pre_path"
		fi
	fi
	echo "Adding $1 ..."
	if [ "$(grep "privpath $pre_path" "$glftpd_conf" | grep -c "$1")" -gt 0 ]; then
		echo "The $pre_path/$1 line already exists in $glftpd_conf."
		log "$pre_path/$1 line already exists in $glftpd_conf" "WARN"
	else
		echo "Trying to add $pre_path/$1 to $glftpd_conf ..."
		/bin/addaffil "$glftpd_conf" "$1" "$pre_path"
		log "Adding $pre_path/$1 to $glftpd_conf" "INFO"
	fi
	if [ -d "$pre_path/$1" ]; then
		echo "The dir $pre_path/$1 already exists, making sure it has permissions set to 777 ..."
		log "$pre_path/$1 already exists" "ERROR"
		chmod 777 "$pre_path/$1"
		log "permissions got updated to 777 for ""$pre_path"/"$1""" "INFO"
		echo "Couldn't create $pre_path/$1 dir since it already existed. permissions got updated to 777."
		echo "Group $1 can start preing now!!!"
		log "GRP $1 is able to pre now!" "INFO"
	else
		mkdir -m777 "$pre_path/$1" >/dev/null 2>&1
		mkdirres=$?
		if [ $mkdirres -ne 0 ]; then
			echo "Error! Couldn't create $pre_path/$1."
			echo "Removing the $pre_path/$1 dir from $glftpd_conf ..."
			log "$pre_path/$1 couldnt be created\n GRP $1 removed from $glftpd_conf " "ERROR"
			lines_num=$(< "$glftpd_conf" wc -l)
			/bin/delaffil "$glftpd_conf" "$1" "$pre_path" "$lines_num"
			echo "Group $1 wasn't set as an affil and it can't pre."
			log "Unable to add $1 as AFFil on $sitename" "ERROR"
		else
			echo "The $pre_path/$1 dir has been created." 
			echo "Group $1 can start preing now!!!"
			log "$pre_path/$1 dir has been created and $1 is able to pre on $sitename" "INFO"
		fi
	fi
else
	echo "Syntax: SITE ADDAFFIL <group> [pre_dir_path]"
fi
