#!/bin/bash

declare -A loglevels=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
script_logging_level="INFO"

# Check if .conf file exists and source it
pre_conf="$(dirname "$0")/pre.conf"
if [ -s "$pre_conf" ]; then
	# shellcheck source=pre.conf
	source "$pre_conf" || {
		echo "[ERROR] could not load $pre_conf"
		exit 1
	}
fi

log() {
	if [[ "${loglevels[$2]}" != "" && ${loglevels[$2]} -ge ${loglevels[$script_logging_level]} ]]; then
		echo "$(date '+%Y-%m-%d %H:%M:%S') [PRE] ${2}: ADDAFFIL - ${1}" >>"$logpath"/rg-pre.log
	fi
}

if [ $# -ge 1 ]; then
	if [ $# -eq 2 ]; then
		pre_path=$2
	else
		pre_path=$base_pre_path
	fi
	if [[ "${pre_path:1:5}" != "/site" ]]; then
		pre_path="/site${pre_path#/}"
	fi
	echo "Adding $1 ..."
	if grep -q "privpath $pre_path" "$glftpd_conf" && grep -q "$1" <<<"$(grep "privpath $pre_path" "$glftpd_conf")"; then
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
		log "permissions got updated to 777 for $pre_path/$1" "INFO"
		echo "Couldn't create $pre_path/$1 dir since it already existed. permissions got updated to 777."
		echo "Group $1 can start preing now!!!"
		log "GRP $1 is able to pre now!" "INFO"
	else
		mkdir -m777 "$pre_path/$1" >/dev/null 2>&1
		mkdirres=$?
		if [ $mkdirres -ne 0 ]; then
			echo "Error! Couldn't create $pre_path/$1."
			echo "Removing the $pre_path/$1 dir from $glftpd_conf ..."
			log "$pre_path/$1 couldn't be created. GRP $1 removed from $glftpd_conf" "ERROR"
			lines_num=$(wc -l <"$glftpd_conf")
			/bin/delaffil "$glftpd_conf" "$1" "$pre_path" "$lines_num"
			echo "Group $1 wasn't set as an affiliate and it can't pre."
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
