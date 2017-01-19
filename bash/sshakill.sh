#!/bin/bash
#
# clears orphaned ssh-agent and apache process left after X-sessions
# @Zvk : 2016
#

if [ "$EUID" -ne 0 ]; then 
  echo -e "\n\e[37m***************************************"
  echo -e "** \e[31mNot running with root privileges!\e[37m **"
  echo -e "***************************************\e[0m\n"
  exit
fi

echo -e "\n- checking process list [ssh-agent]"
pids=($(ps -aux | grep -E "ssh-agent -s$" | awk '{ print $2 }'))
echo "- number of elements in array: ${#pids[@]}"
echo "- closing ssh-agent processes"
for i in "${pids[@]}"; do
	kill -9 $i
done
sigkills=${#pids[@]}
echo -e "\n- checking process list [apache2]"
pids=($(ps -aux | grep -E "apache2 -k start$" | awk '{ print $2 }'))
echo "- number of elements in array ${#pids[@]}"
echo "- closing apache2 processes"
for i in "${pids[@]}"; do
	kill -9 $i
done
sigkills=$(($sigkills + ${#pids[@]}))
echo -e "\n- closed $sigkills processes"; echo
