#!/bin/bash
#
# Prints configured users (uid above 1000), input is taken from passwd database
# A little bit changed form so that it works on Ubuntu as well, but changes are made
# only to allow that, no optimalization, cleaning up, since I no longer use this script
# @MZvk : 2017 [A54477]
#

action(){
  [[ ! $1 =~ ^a[0-9]{6}$ ]] && \
    echo -e "\e[31m*ERROR:\e[0m \e[36m$user\e[0m cannot be modified by script." && return 0
  [[ -z $(grep "$1" <(getent passwd)) ]] && \
    echo -e "\e[31m*ERROR:\e[0m \e[36m$user\e[0m does not exist." && return 0
  case $2 in
    r) echo -e "\e[33m*DONE:\e[0m Restoring user $1" && usermod -e "" $1 2>/dev/null ;;
    e) echo -e "\e[33m*DONE:\e[0m Suspending user $1" && usermod -e 1 $1 2>/dev/null ;;
    d) echo -e "\e[33m*DONE:\e[0m Removing user $1 [dry run]";;
    b) echo -e "\e[33m*DONE:\e[0m User $1 is banned"
       [[ `grep -q '. /etc/ban-profile/' /home/$1/.profile` ]] && echo '. /etc/ban-profile/' >> /home/$1/.profile ;;
    u) echo -e "\e[33m*DONE:\e[0m User $1 in unbanned" && sed -i '/\. \/etc\/ban-profile/d' /home/$1/.profile ;;
    *) ;;
  esac
}

usage(){
  cat <<- EOL
+-[MZvk 2017 A544778]-------------------------------------------------------+
 INFO: Lists configured lab users with uid above 1000, also when  options
 are provided, user account can be modified.  For options usage, root
 priviliages are required!
 Only one action is permitted, rest will be ignored.
 Only users which login is DAS ID, can be modified.
 Others must be modified manually to avoid misconfig.
 USAGE: $(basename $0) [OPTIONS] [[ACTIONS] <user_id>]
 Examples:
        $(basename $0)
        $(basename $0) -s -e a000001
 OPTIONS:
  -h   Prints this help message
  -s   Works in silent mode (does not display user table)
 ACTIONS:
  -e   Locks account by setting it to be expired
  -r   Unlocks account by clearing expiriation date
  -b   Ban user account
  -u   Unban user account (must be banned with same method as -b)
  -d   Removes user account  [NOT IMPLEMENTED]
+--------------------------------------------------------------------------+
EOL
  exit 0
}

last_login() {
  ldate=`lastlog -u $1 | tail -1`
  if [[ $ldate =~ "Never logged in" ]]; then
    ldate="never"
  elif [[ $ldate =~ "tty" ]]; then
      ldate=`echo $ldate | date -d "$(awk '{printf "%s %s %s %s", $5, $4, $8, $6 }')" "+%d.%m.%Y %H:%M:%S"`
  else
      ldate=`echo $ldate | date -d "$(awk '{printf "%s %s %s %s", $6, $5, $9, $7 }')" "+%d.%m.%Y %H:%M:%S"`
  fi
  echo $ldate
}

check_status() {
  local sts=0
  since1970=$(($(date --utc --date " " +%s)/86400))
  bn=`grep "$1" /etc/shadow | cut -d: -f8`
  [[ -n `grep ". /etc/ban-profile" /home/$1/.profile` ]] && ((sts+=2))
  [[ ${bn:-$since1970} < $since1970 ]] && ((sts+=1))
  case $sts in
    1) echo "*";;
    2) echo "!";;
    3) echo "#";;
    *) echo " ";;
  esac
}

if [ "$EUID" -eq 0 ]; then
  while getopts ":e:r:d:b:u:hs" opt; do
    case "${opt}" in
      e|r|d|b|u) [[ -z "$user" ]] && user=$OPTARG && optdo=$opt && action $user $opt || \
             echo -e "\e[34m*INFO*:\e[0m Single action is permitted, ignoring: \"-$opt $OPTARG\".";;
          s) silent=1 ;;
          h) usage ;;
         \?) echo -e "\e[31m*ERROR:\e[0m Invalid option: -$OPTARG. Use -h for help." >&2 ;;
          :) echo -e "\e[31m*ERROR:\e[0m Option -$OPTARG requires an argument." >&2 ;;
    esac
  done
fi

if [[ -z "$silent" ]]; then
  echo -e "+-----------------+---------------------+------+------+----------------------+------ ---- -- - "
  echo -e "|       \e[33muser\e[0m      |     \e[33mlast login\e[0m      | \e[33muid\e[0m  | \e[33mgid\e[0m  | \e[33mfull name\e[0m            | \e[33memail\e[0m "
  echo    "+-----------------+---------------------+------+------+----------------------+------------- --- -- -"
  if [ "$EUID" -eq 0 ]; then
    getent passwd | awk -F'[:]' '$3 >= 1000 && $3 < 5000 { gsub(/ /, "#", $5); split($5, x, ","); print $1" "$3" "$4" "x[1]" "x[5] }' | while read line; do
      user=($line)
      printf "|\033[31m%s\033[0m%-15s | %-19s | %.4d | %.4d | %-20s | %s \n" "$(check_status ${user[0]})" ${user[0]} "$(last_login ${user[0]})" ${user[1]} ${user[2]} "${user[3]//#/ }" ${user[4]}
    done
  else
    getent passwd | awk -F'[:]' '$3 >= 1000 && $3 < 5000 { gsub(/ /, "#", $5); split($5, x, ","); print $1" "$3" "$4" "x[1]" "x[5] }' | while read line; do
      user=($line)
      printf "| %-15s | %-19s | %.4d | %.4d | %-20s | %s \n" ${user[0]} "$(last_login ${user[0]})" ${user[1]} ${user[2]} "${user[3]//#/ }" ${user[4]}
    done
  fi
  echo "+-----------------+---------------------+------+------+----------------------+----- --- --- -- - "
  if [ "$EUID" -eq 0 ]; then
    echo -e " \e[31m*\e[0m - expired users"
    echo -e " \e[31m!\e[0m - banned users"
    echo -e " \e[31m#\e[0m - expired & banned"
  fi
fi
