#!/bin/bash
#
# prints all active login shells for either all or specified users
# @Zvk A544778
#

if [[ $# -lt 1 ]]; then
  declare -A pidmap
  for x in `ps aux | grep -e "\-bash$" | awk '{print $1":"$2}'`; do
    x=(${x//:/ })
    if [[ ${pidmap[${x[0]}]+_} ]]; then pidmap[${x[0]}]+=" ${x[1]}"; else pidmap[${x[0]}]+=${x[1]}; fi
  done
  echo "Found ${#pids[@]} active login shell(s) for ${#pidmap[@]} user(s)"
  for usr in ${!pidmap[@]}; do
    printf " %-10s: \e[31m%s\e[0m\n" "$usr" "${pidmap[$usr]}"
  done && echo
else
  uarg=($(echo "$@" | tr ' ' '\n' | sort -u | tr '\n' ' '))
  for arg in "${uarg[@]}"; do
    if [[ -z $(getent passwd | grep -e "^$arg:") ]]; then echo -e "\e[33mUser $arg does not exist on this system.\e[0m" && continue; fi
    psu=`ps -fu $arg | grep "\-bash$" | awk '{print $2}'`
    if [[ -z $psu ]]; then echo -e "\e[33mUser $arg does not have active login shells.\e[0m" && continue; fi
    echo -e "$arg - ${#pids[@]} active login shell(s): \e[31m"$psu"\e[0m"
  done
fi
