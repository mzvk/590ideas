#!/bin/bash
#
# Prints configured users (uid above 1000), input is taken from passwd database
# @MZvk : 2017 [A54477]
#

action(){
  [[ ! $1 =~ ^a[0-9]{6}$ ]] && \
    echo -e "\e[31m*ERROR:\e[0m \e[34m$user\e[0m cannot be modified" && return 0
  [[ -z $(grep $1 <(getent passwd)) ]] && \
    echo -e "\e[31m*ERROR:\e[0m \e[34m$user\e[0m does not exist" && return 0
  case $2 in
    r) echo -e "\e[33m*DONE:\e[0m Restoring user $1" && usermod -e "" $1 2>/dev/null ;;
    e) echo -e "\e[33m*DONE:\e[0m Suspending user $1" && usermod -e 1 $1 2>/dev/null ;;
    *) ;;
  esac
}

usage(){
  cat <<- EOL

Lists configured lab users with uid above 1000, also when options are provided,
user account can be modified. For options usage, root priviliages are needed.
@MZvk 2017 [A544778]

Usage: $(basename $0) [-r|e [user]]
       Only one action is permitted, rest will be ignored
Options:
 -h   Prints this help message
 -e   Locks account by setting it to be expired
 -r   Unlocks account by clearing expiriation date

EOL
  exit 0
}

if [ "$EUID" -eq 0 ]; then
  while getopts ":e:r:h" opt; do
    case "${opt}" in
      e|r) [[ -z "$user" ]] && user=$OPTARG && optdo=$opt && action $user $opt || \
           echo -e "\e[34m*INFO*:\e[0m Single action is permitted, ignoring: \"-$opt $OPTARG\".";;
        h) usage ;;
       \?) echo -e "\e[31m*ERROR:\e[0m Invalid option: -$OPTARG. Use -h for help." >&2 ;;
        :) echo -e "\e[31m*ERROR:\e[0m Option -$OPTARG requires an argument." >&2 ;;
    esac
  done
fi

s1970=$(($(date --utc --date " " +%s)/86400))
echo -e "\n+---------+------+------+----------------------+------ ---- -- - "
echo -e "|  \e[33muser\e[0m   | \e[33muid\e[0m  | \e[33mgid\e[0m  | \e[33mfull name\e[0m            | \e[33memail\e[0m "
echo "+---------+------+------+----------------------+------------- --- -- -"
if [ "$EUID" -eq 0 ]; then
getent passwd | awk -v epoch="$s1970" -F'[:,]' '$3 >= 1000 && $3 < 5000 \
                {ch = 0; for(col = 6; col <= NF; col++){if(match($col, /.*@.*/) && ch != col) {ch = col; mail = $col}} \
                if(ch == 0) mail = " --- "; \
                {cmd = "grep "$1" /etc/shadow | cut -d: -f8"; cmd |getline uexp; close(cmd); usts = " ";} \
                if(uexp !~ /^$/ && uexp < epoch) usts = "\033[31m*\033[0m"; \
                printf "|%s%-7s | %.4d | %.4d | %-20s | %s \n", usts, $1, $3, $4, $5, mail}' | sort -t'|' -nk3
else
getent passwd | awk -F'[:,]' '$3 >= 1000 && $3 < 5000 \
                {ch = 0; for(col = 6; col <= NF; col++){if(match($col, /.*@.*/) && ch != col) {ch = col; mail = $col}} \
                if(ch == 0) mail = " --- "; \
                printf "| %-7s | %.4d | %.4d | %-20s | %s \n", $1, $3, $4, $5, mail}' | sort -t'|' -nk3
fi
echo "+---------+------+------+----------------------+----- --- --- -- - "
echo -e " \e[31m*\e[0m - expired users (only for root)"

#ideas
# -a/d - add/del account

