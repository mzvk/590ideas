#!/bin/bash --
#
# closes all interactive login shells (-bash) apart from one that script was initiated
# @Zvk : 2017
#

declare -A pidmap

function searchflag {
  local array
  for array; do [[ "$array" == "+all" ]] && return 0; done
  return 1
}

function get_cpid {
  local subpid=$(echo "`ps -ef | awk '{print $2" "$3}' | grep -e "^$$" | cut -d' ' -f2`")
  [[ $EUID -eq 0 && $SUDO_COMMAND =~ ^($BASH )?$0 ]] && cpid=$(echo "`ps -ef | awk '{print $2" "$3}' | grep -e "^$subpid" | cut -d' ' -f2`") || cpid=$subpid
}

if [[ $# -lt 1 ]]; then echo -e "\e[31m ** No user specified - script terminated **\e[0m" && exit 1; fi
if [[ $EUID -ne 0 ]]; then echo -e "\e[31m ** No root permissions detected - elevating **\e[0m" && sudo='sudo'; fi

pids=()
usrs=()
get_cpid
uarg=($(echo "$@" | tr ' ' '\n' | sort -u | tr '\n' ' '))
if searchflag "${uarg[@]}"; then
  for x in `ps aux | grep "\-bash$" | awk '{print $1"-"$2}'`; do
    x=(${x//-/ })
    pids+=(${x[1]})
    if [[ ${pidmap[${x[0]}]+_} ]]; then pidmap[${x[0]}]+=" ${x[1]}"; else pidmap[${x[0]}]+=${x[1]}; fi
  done
  echo "Found ${#pids[@]} active login shell(s) for ${#pidmap[@]} user(s)"
  for usr in ${!pidmap[@]}; do
    printf " %-10s: \e[31m%s\e[0m\n" "$usr" "${pidmap[$usr]}"
  done && echo
else
  for arg in "${uarg[@]}"; do
    if [[ -z $(getent passwd | grep -e "^$arg:") ]]; then echo -e "\e[33mUser $arg does not exist on this system.\e[0m" && continue; fi
    psu=`ps -fu $arg | grep "\-bash$" | awk '{print $2}'`
    if [[ -z $psu ]]; then echo -e "\e[33mUser $arg does not have active login shells.\e[0m" && continue; fi
    pids+=($psu)
    echo -e "$arg - $((${#pdu[@]} + 1)) active login shell(s): \e[31m"$psu"\e[0m"
  done
fi
echo " ** Closing all sessions **"
for pid in "${pids[@]}"; do
  if [[ $pid == $cpid ]]; then
    echo -e "\e[33mIgnoring current user login shell [$cpid]\e[0m"
  else
    $sudo echo -n "closing session $pid..." ## sudo'd just so prompt for sudo will not mess print-out :V
    error=`$sudo kill -9 $pid 2>&1 | sed 's/.*kill: //'`
    if [[ -z $error ]]; then echo -e "\e[35mdone\e[0m"; else echo -e "\e[31m$error\e[0m"; fi
  fi
done
