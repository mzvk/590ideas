#!/bin/bash --
#
# Gets VM list from ESX and connects to VMRC of selected one
# Note: there's no error checking!
# @Zvk : 2016
#

user='root'
host='192.168.242.10'

counter=0
moref=()
names=()
guest=()

echo -n "> Retriving VM list... "
output=$(ssh -o ConnectTimeout=1 $user@$host 'vim-cmd vmsvc/getallvms' 2>/dev/null)
[[ -z $output ]] && { echo -e "[failed]\n[error] - SSH connection failed"; exit; }
grep_test=$(echo $output | grep -oP "^[a-zA-Z]+")

if [[ $grep_test == Vmid ]]; then
   echo "[done]";
   while read -r line; do
      if [ $(echo $line | grep -oP "^[0-9]+") ]; then
         moref[$counter]=$(awk '{print $1}' <(echo $line))
         names[$counter]=$(awk '{print $2}' <(echo $line))
         guest[$counter]=$(awk '{print $5}' <(echo $line))
         echo $(awk '{print $1}' <(echo $line))
         ((counter++))
      fi
   done < <(echo "$output")
else
   echo "[error] - data corrupted"
   exit 100
fi

echo; echo "> Choose VM to which you want to connect"
echo "------------------------------"
echo -e "ID  Name\tGuest_OS"
echo "------------------------------"
for ((i=0; i<$counter; i++)); do
   echo -e "$i   ${names[$i]}\t${guest[$i]}"
done
read -s vmid
echo "Trying to connect to ${names[$vmid]} (you will be prompted for password)"
vmrc -H $host -U $user -M ${moref[$vmid]}
