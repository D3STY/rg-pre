#!/bin/bash
# Command parameters for this script as they are being passed by glftpd:
# $1 = The directory to pre.
# $2 = Section.
#
# Logging to glftpd.log (for the sitebot) is being done in the following format:
# PRE: <target_path/dirname> <group> <section> <files_num> <dir_size> <user> <genre>

# Check if .conf file exist, source if it does
pre_conf="$(dirname "$0")/$(basename -s '.sh' "$0").conf"
# shellcheck source=rg-pre.conf
[ -s "$pre_conf" ] && source "$pre_conf" || {
    echo "[ERROR] could not load $pre_conf"
    exit 1
}

declare -A loglevels=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
script_logging_level="INFO"

log() {
    local log_level_num=${loglevels[$2]:-}
    local script_log_level_num=${loglevels[$script_logging_level]:-}
    
    if [ "$log_level_num" != "" ] && [ "$log_level_num" -ge "$script_log_level_num" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [PRE] $2: ${pregrp} - $1" >>"$logpath/rg-pre.log"
    fi
}

check_logfile() {
    local log_file="$1"
    [ -f "$log_file" ] && [ -w "$log_file" ] || {
        local log_dir="$(dirname "$log_file")"
        [ -w "$log_dir" ] || {
            echo "Logfile $log_file does not exist, or you do not have permission to create it."
            exit 1
        }
        touch "$log_file"
        chmod 666 "$log_file"
    }
}

## Main block ##

{ [ -z "$1" ]; } && {
    echo ",----=[- RG-pre -]=----------------------."
    echo '| Usage: SITE PRE <dirname> <section>'
    echo '| Valid sections: ' "${section_name[*]}"
    [ "$allowdefaultsection" -eq 1 ] && echo '| If you do not specify a section then' && echo "| the release will be pre'd to ${section_name[$defaultsection]}."
    echo '| This moves a directory from a pre-dir to'
    echo '| the provided section dir, and logs it.'
    echo '`---------------------------------------------'
    exit 0
}

if [ $# -lt 2 ]; then
    if [ "$allowdefaultsection" -eq 1 ]; then
        sect=${section_name[$defaultsection]}
        default_section_used=true
    else
        echo "Second parameter wasn't specified and there is no default section defined. Aborting ..."
        log "Section wasn't specified and auto / default section is not defined" "ERROR"
        exit 1
    fi
else
    sect=$2
    sect=$(echo "$sect" | tr '[:lower:]' '[:upper:]')
    log "Release $1" "INFO"
    log "Section $sect" "INFO"
fi

if [ "$default_section_used" = true ]; then
    echo "Second parameter wasn't specified, using $sect by default ..."
    log "No Section specified, using $sect in automode" "INFO"
fi

# Check for existence and writability of the rg-pre, glftpd.log, and dupelog.
for log_file in "$logpath/rg-pre.log" "$logpath/glftpd.log" "$logpath/dupelog"; do
    check_logfile "$log_file"
done

pwd=$(pwd)
# shellcheck source=rg-pre.conf
predirs=$(grep <"$glftpd_conf" privpath | awk '{print $2}')

# Check that the user is in a valid pre directory.
if ! [[ $predirs =~ (^|[[:space:]])"$pwd"($|[[:space:]]) ]]; then
    echo "Please enter a pre dir before running SITE PRE."
    echo "Current dir is $pwd."
    log "$USER not inside a valid PRE dir - $PWD" "ERROR"
    exit 1
fi

# Check that the specified pre-release dir exists.
[ -d "$1" ] || {
    echo "$1 is not a valid directory."
    log "Invalid directory $1 for PRE" "INFO"
    exit 1
}

# Check that the specified pre-release dir resides within the current pre dir.
if ! (cd "$1" && pwd | grep -q "$pwd/"); then
    echo "The specified directory does not reside below the pre dir you are in."
    log "The specified directory does not reside below the pre dir." "ERROR"
    exit 1
fi

# Check that the current directory and the specified directory are writable.
[ -w "$pwd" ] || {
    echo "You do not have write permissions to the current directory,"
    log "No write permissions for the current directory - $pwd" "ERROR"
    exit 1
}

[ -w "$1" ] || {
    echo "You do not have write permissions to the release dir specified"
    log "No write permissions to the release dir - $1" "ERROR"
    exit 1
}

pregrp=$(basename "$pwd")

# Use du to get the size in kilobytes and calculate it in one line
size=$(($(du -sk "$1" | cut -f1) / 1024))

# Use a for loop to find the index of the section name
found=0
for ((index = 0; index < sections_num; index++)); do
    if [ "${section_name[$index]}" = "$sect" ]; then
        found=1
        break
    fi
done

if [ $found -eq 1 ]; then
    target=${section_target_path[$index]}
    preinfo_script=${section_script_path[$index]}
    
    # Fix ABOOK pre in MP3
    if [ "${sect}" = "MP3" ]; then
        case "${1^^}" in
            *-AUDIOBOOK-* | *-ABOOK-*)
                sect=${section_name[2]}
                target=${section_target_path[2]}
                preinfo_script=${section_script_path[2]}
            ;;
            *) echo "Section was automatically corrected to \"$sect\"" ;;
        esac
    fi
    
    # Check if the preing dir actually exists
    if [ ! -d "$target" ]; then
        echo "Target dir for preing doesn't exist!"
        log "Section for pre doesn't exist!" "ERROR"
        exit 1
    fi
    
    # Check that another release by the current name doesn't already exist
    if [ -d "$target/$(basename "$1")" ]; then
        echo "$(basename "$1") already exists in today's dir!"
        log "Dupe $(basename "$1")" "ERROR"
        exit 1
    fi
    
    # Calculate the number of files using find and grep
    files=$(find "$1" | grep -cE "\.[[:alnum:]]{3}$")
    
    # Calculate preinfo or use the specified script
    if [ -n "$preinfo_script" ]; then
        preinfo=$($preinfo_script "$pwd/$1")
    else
        preinfo="$sect"
    fi
    
    # Add to dupelog
    /bin/dupediradd "$1" "$datapath" >/dev/null 2>&1
    
    # Set the current time on the release dir
    touch "$1"
    
    # Move the release
    mv "$1" "$target"
    
    # Put a record in glftpd.log
    echo "$(date '+%a %b %d %T %Y')" PRE: \""$target""/$1"\" \""$sect""\" \"$pregrp"\" \""$files""\" \"$preinfo"\" \""$size""\" \"$USER"\" >>"$logpath"/glftpd.log
    log "Putting a record in glftpd.log" "INFO"
    log "\"""$target"""/"$1""\" \"""$sect"""\" \""$pregrp""\" \"""$files"""\" \""$preinfo""\" \""$size""\" \""$USER""\"" "INFO"
    echo "[$sitename] Success! Release has been pre'd. [$sitename]"
else
    echo "Section $sect doesn't exist. Aborting ..."
    log "Invalid Section $sect" "ERROR"
    exit 1
fi
