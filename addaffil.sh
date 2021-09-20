#!/bin/bash

# Check if .conf file exist, source if it does
pre_conf="$(dirname "$0")/pre.conf"
if [ -s "$pre_conf" ]; then
	. "$pre_conf" || { echo "[ERROR] could not load $pre_conf"; exit 1; }
fi

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
	else
		echo "Trying to add $pre_path/$1 to $glftpd_conf ..."
		/bin/addaffil "$glftpd_conf" "$1" "$pre_path"
	fi
	if [ -d "$pre_path/$1" ]; then
		echo "The dir $pre_path/$1 already exists, making sure it has permissions set to 777 ..."
		chmod 777 "$pre_path/$1"
		echo "Couldn't create $pre_path/$1 dir since it already existed. permissions got updated to 777."
		echo "Group $1 can start preing now!!!"
	else
		mkdir -m777 "$pre_path/$1" >/dev/null 2>&1
		mkdirres=$?
		if [ $mkdirres -ne 0 ]; then
			echo "Error! Couldn't create $pre_path/$1."
			echo "Removing the $pre_path/$1 dir from $glftpd_conf ..."
			lines_num=$(< "$glftpd_conf" wc -l)
			/bin/delaffil "$glftpd_conf" "$1" "$pre_path" "$lines_num"
			echo "Group $1 wasn't set as an affil and it can't pre."
		else
			echo "The $pre_path/$1 dir has been created."
			echo "Group $1 can start preing now!!!"
		fi
	fi
else
	echo "Syntax: SITE ADDAFFIL <group> [pre_dir_path]"
fi
