#! /bin/bash
glftpd_conf="/etc/glftpd.conf"
base_pre_path="/site/PRE"

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
   lines_num=$(< $glftpd_conf wc -l)
   /bin/delaffil $glftpd_conf "$1" $pre_path "$lines_num"
   if [ -d "$pre_path/$1" ]; then
      rm -rf "${pre_path:?}/""$1"
      echo "Success! $pre_path/$1 has been removed."
      echo "Group $1 is NO LONGER affiled on this site!!!"
   else
      echo "The $1 directory doesn't exist, there is no pre dir to remove."
      echo "Group $1 wasn't fully set or didn't exist, however it got fully removed now!"
   fi
else
   echo "Syntax: SITE DELAFFIL <group> [pre_dr_path]"
fi
fi