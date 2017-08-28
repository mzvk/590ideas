#!/bin/bash

declare -A pidmap

function searchflag {
  local array
  for array; do [[ "$array" == "+all" ]] && return 0; done
  return 1
}

### check sudo
function get_cpid {
  local subpid=$(echo "`ps -ef | awk '{print $2" "$3}' | grep -e "^$$" | cut -d' ' -f2`")
  cpid=$(echo "`ps -ef | awk '{print $2" "$3}' | grep -e "^$subpid" | cut -d' ' -f2`")
}

pids=()
usrs=()

get_cpid
if [[ $# -lt 1 ]]; then echo -e "\e[31mNo user specified - script terminated.\e[0m" && exit 1; fi
if [[ "$EUID" -ne 0 ]]; then echo -e "\e[31mNo ROOT permissions - script terminated.\e[0m" && exit 1; fi
uarg=($(echo "$@" | tr ' ' '\n' | sort -u | tr '\n' ' '))

if searchflag "${uarg[@]}"; then
  for x in `ps aux | grep -e "\-bash$" | awk '{print $1"-"$2}'`; do
    x=(${x//-/ })
    pids+=(${x[1]})
    if [[ ${pidmap[${x[0]}]+_} ]]; then pidmap[${x[0]}]+=" ${x[1]}"; else pidmap[${x[0]}]+=${x[1]}; fi
  done
  echo "Found ${#pids[@]} active login shell(s) for ${#pidmap[@]} user(s)"
  for usr in ${!pidmap[@]}; do
    printf " %-10s: %s\n" "$usr" "${pidmap[$usr]}"
  done && echo
else
  for arg in "${uarg[@]}"; do
    unset pids
    if [[ -z $(getent passwd | grep -e "^$arg:") ]]; then
      echo -e "\e[33mUser $arg does not exist on this system.\e[0m" && continue
    fi
    psu=`ps -fu $arg | grep "\-bash$" | awk '{print $2}'`
    if [[ -z $psu ]]; then
      echo -e "\e[33mUser $arg does not have active login shells.\e[0m" && continue
    fi
    pids+=($psu)
    echo -e "$arg - ${#pids[@]} active login shell(s): \e[31m"$psu"\e[0m"
  done
fi
echo "Closing all sessions"
for pid in "${pids[@]}"; do
  if [[ $pid == $cpid ]]; then
    echo -e "\e[33mIgnoring current user login shell [$cpid]\e[0m"
  else
    echo -n "closing session $pid..."
    kill -9 $pid && echo -e "\e[33mdone\e[0m"
  fi
done

