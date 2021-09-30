#!/bin/bash
#
#
#
# Command parameters for this script as they are being passed by glftpd:
# $1 = The directory to pre.
# $2 = Section.
#
# Logging to glftpd.log (for the sitebot) is being done in the following format:
# PRE: <target_path/dirname> <group> <section> <files_num> <dir_size> <user> <genre>
# Check if .conf file exist, source if it does
pre_conf="$(dirname "$0")/$(basename -s '.sh' "$0").conf"
if [ -s "$pre_conf" ]; then
	. "$pre_conf" || { echo "[ERROR] could not load $pre_conf"; exit 1; }
fi

declare -A loglevels=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
script_logging_level="INFO"
log() {
	if [[ "${loglevels[$2]}" != "" && ${loglevels[$2]} -ge ${loglevels[$script_logging_level]} ]]; then
		echo "$(date '+%Y-%m-%d %H:%M:%S') [PRE] ${2}: ${pregrp} - ${1}"  >>"$logpath"/rg-pre.log
	fi
}
# Config checks
if [ -z "$sitename" ]; then
	echo "[ERROR] sitename is not set correctly, exiting..."; exit 1
	log "Sitename is not set correctly" "ERROR"
fi

checklogfile() {
	# Check for existence and writability of logfile.
	if [ -f "$1" ]; then
		[ -w "$1" ] || {
			echo "Logfile $1 exists, but"
			echo "is not writable by you. Please verify its permissions."
			exit 1
		}
	else
		if [ -w "$(dirname "$1")" ]; then
			touch "$1"
			chmod 666 "$1"
		else
			echo "Logfile $1 does not exist,"
			echo "and you do not have permission to create it."
			exit 1
		fi
	fi
}

## Main block ##

{ [ -z "$1" ]; } && {
	echo ",------------------------------=[- RG-pre -]=--."
	echo '| Usage: SITE PRE <dirname> <section>'

	echo '| Valid sections:'
	echo -n '| '
	for sect in "${section_name[@]}"; do
		echo -n "$sect "
	done
	echo ""

	if [ "$allowdefaultsection" -eq 1 ]; then
		echo '|'
		echo '| If you do not specify a section then'
		echo "| the release will be pre´d to ${section_name[$defaultsection]}."
	fi

	echo '|'
	echo '| This moves a directory from a pre-dir to'
	echo '| the provided section dir, and logs it.'
	echo '`---------------------------------------------'
	exit 0
}

if [ $# -lt 2 ]; then
	if [ "$allowdefaultsection" -eq 1 ]; then
		sect=${section_name[$defaultsection]}
		echo "Second parameter wasn't specified, using $sect by default ..."
		log "No Section specified, using $sect in automode" "INFO"
	else
		echo "Second parameter wasn't specified and there is no default section defined. Aborting ...";
		log "Section wasn't specified and auto / default section in not definied" "ERROR";
		exit 0
	fi
else
	sect=$2
	log "Section ""$2""" "INFO"
fi

# Converting section to uppercase
sect=$(echo "$sect" | tr '[:lower:]' '[:upper:]')

# Check for existence and writability of the rg-pre.
checklogfile "$datapath/logs/rg-pre.log"

# Check for existence and writability of the glftpd.
checklogfile "$datapath/logs/glftpd.log"

# Check for existence and writability of the dupelog.
checklogfile "$datapath/logs/dupelog"

pwd=$PWD
predirs=$(< "$glftpd_conf" grep privpath | awk '{print $2}')

# Check that the user is currently in a valid pre directory.
inpredir=0
for predir in $predirs; do
	[ "$pwd" = "$predir" ] && {
		inpredir=1
		break
	}
done
[ "$inpredir" = "0" ] && {
	echo "Please enter a pre dir before running SITE PRE."
	echo "Current dir is $pwd."
	log ""$USER" not inside a valid PRE dir - "$PWD"" "ERROR"
	exit 1
}

# Check that the specified pre-release dir does in fact exist.
[ -d "$1" ] || {
	echo "\"$1\" is not a valid directory."
	log "Selected ""$1"" for PRE" "INFO"
	exit 1""
}
(
	cd """$1"""
	pwd
) | grep "$pwd/" >/dev/null || {
	echo "The specified dir does not reside below the pre dir you are in."
	log "The specified dir does not reside below the pre dir you are in." "ERROR"
	exit 1
}

# Check that the current directory is writable so we can move stuff from it.
[ -w """$pwd""" ] || {
	echo "You do not have write permissions to the current directory,"
	log "No write permissions for the current directory" "ERROR"
	exit 1
}

# Check that we actually have write permission to the rls dir, so we
# can move it properly
[ -w "$1" ] || {
	echo "You do not have write permissions to the release dir specified"
	log "No write permissions to the release dir - ""$1" "ERROR"
	exit 1
}

pregrp=$(basename "$pwd")
# The -sk is used instead of -sm for BSD and Solaris compartibility
size_k=$(($(du -sk "$1" | cut -f1)))
size=$((size_k/1024))

found=0
index=0
sections_num=${#section_name[@]}
while [ $index -lt "$sections_num" ] && [  $found -eq 0 ]; do
	if [ "${section_name[$index]}" = "$sect" ]; then
		found=1
	else
		index=$((index+1))
	fi
done

if [ $found -eq 1 ]; then
	target=${section_target_path[$index]}
	preinfo_script=${section_script_path[$index]}
	# Check if the preing dir actually exist
	[ -d "$target" ] || {
		echo "Target dir for preing doesn't exist!"
		log "Section for pre doesent exist!" "ERROR"
		exit 1
	}
	# Check that another release by the current name doesn't already exist
	[ -d "$target/$(basename "$1")" ] && {
		echo "$(basename "$1") already exists in today's dir!"
		log "Dupe $(basename "$1")" "ERROR"
		exit 1
	}
	# Calculating different values
	files=$(find "$1" | grep -cE "\.[[:alnum:]]{3}$")
	if [ "$preinfo_script" != "" ]; then
		preinfo=$($preinfo_script "$pwd/$1")
	else
		preinfo="$sect"
	fi

	# Fix ABOOK pre in MP3
	if [ "${sect}" = "MP3" ]; then
		case $target/"{$1^^}" in
			*\-AUDIOBOOK\-*|*\-ABOOK\-*) sect="ABOOK-DE";;
			*) log "Route pre to ${sect}" "WARN";;
		esac
	fi

	# Adding to dupelog
	/bin/dupediradd "$1" "$datapath" >/dev/null 2>&1
	echo "[$sitename] Release Info: $preinfo [$sitename]"
	log "Release Info: "$preinfo"" "INFO"
	# Setting the current time on the release dir
	touch "$1"
	# Moving the release
	mv "$1" "$target"
	# Putting a record in glftpd.log
	echo "$(date '+%Y-%m-%d %H:%M:%S')" PRE: \""$target""/$1"\" \""$pregrp""\" \"$sect"\" \""$files""\" \"$size"\" \""$preinfo""\" \"$USER"\" >>"$datapath"/logs/glftpd.log
	log "Putting a record in glftpd.log" "INFO"
	log "RLS: ""$target"""/""$1""  "INFO"
	log "GRP: "$pregrp"" "INFO"
	log "SEC: "$sect"" "INFO"
	log "iNFO: "$preinfo"" "INFO"
	log "F"$files""$size""MB"" "INFO"
	log "USR: "$USER"" "INFO"
	log "Release has been pre'd on $sitename" "INFO"
	echo "[$sitename] Success! Release has been pre'd. [$sitename]"
else
	echo "Section $sect doesn't exist. Aborting ..."
	log "Invalid Section $sect" "ERROR"
	exit 1
fi
