#!/bin/bash
#
#
# Notes:
# 1) Make sure that all pre dir names are exactly the same as the
#    group names they are linked to.
# 2) The following bins are required in glftpd's bin dir:
#    sed, echo, touch, chmod, pwd, grep, basename, date, mv, bash,
#    dupediradd, find
# 3) If you don't have it already compiled in your glftpd's bin dir,
#    you must compile glftpd/bin/sources/dupediradd.c as
#    gfltpd/bin/dupediradd, then chmod 666 ftp-data/logs/dupelog
#    and chmod 666 ftp-data/logs/glftpd.log so they can be written
#    to by all users when they pre.
# 4) Make sure glftpd/dev/null is world writable or you will
#    get strange errors.
# 5) All paths specified in the configuration section of this script
#    should be chrooted to glftpd dir. In other words, you specify
#    /ftp-data and not /glftpd/ftp-data or /jail/glftpd/ftp-data.
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

# Config checks
if [ -z "$sitename" ]; then
	echo "[ERROR] sitename is not set correctly, exiting..."; exit 1
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
	else
		echo "Second parameter wasn't specified and there is no default section defined. Aborting ..."
		exit 0
	fi
else
	sect=$2
fi

# Converting section to uppercase
sect=$(echo "$sect" | tr '[:lower:]' '[:upper:]')

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
	exit 0
}

# Check that the specified pre-release dir does in fact exist.
[ -d "$1" ] || {
	echo "\"$1\" is not a valid directory."
	exit 1
}
(
	cd "$1"
	pwd
) | grep "$pwd/" >/dev/null || {
	echo "The specified dir does not reside below the pre dir you are in."
	exit 1
}

# Check that the current directory is writable so we can move stuff from it.
[ -w "$pwd" ] || {
	echo "You do not have write permissions to the current directory,"
	echo "$pwd, so you can't pre here."
	exit 1
}

# Check that we actually have write permission to the rls dir, so we
# can move it properly
[ -w "$1" ] || {
	echo "You do not have write permissions to the release dir specified,"
	echo "\"$1\"."
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
		exit 1
	}
	# Check that another release by the current name doesn't already exist
	[ -d "$target/$(basename "$1")" ] && {
		echo "$(basename "$1") already exists in today's dir!"
		exit 1
	}
	# Calculating different values
	files=$(find "$1" | grep -cE "\.[[:alnum:]]{3}$")
	if [ "$preinfo_script" != "" ]; then
		preinfo=$($preinfo_script "$pwd/$1")
	else
		preinfo="$sect"
	fi
	# Adding to dupelog
	/bin/dupediradd "$1" "$datapath" >/dev/null 2>&1
	echo "[$sitename] Release Info: $preinfo [$sitename]"
	# Setting the current time on the release dir
	touch "$1"
	# Moving the release
	mv "$1" "$target"
	# Putting a record in glftpd.log
	echo "$(date "+%a %b %d %T %Y")" PRE: \""$target"/"$1"\" \""$pregrp"\" \""$sect"\" \""$files"\" \""$size"\" \""$preinfo"\" \""$USER"\" >>"$datapath"/logs/glftpd.log
	echo "[$sitename] Success! Release has been pre'd. [$sitename]"
else
	echo "Section $sect doesn't exist. Aborting ..."
	exit 1
fi
