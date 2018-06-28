#!/bin/bash
#
# motd for lab vms
# @Zvk : 2016
#

OSVR=`hostnamectl | awk '/System/{print $3}'`' '`[ -r /etc/debian_version ] && cat /etc/debian_version`
CHAS=`hostnamectl | awk '/Chassis/{print $2}'`
VIRT=`hostnamectl | grep Virtualization | awk '{print $2}'`
LOAD=`cat /proc/loadavg | awk '{print $1" "$2" "$3}'`
MEMU=`free | awk '/Mem:/ { printf "%05.2f%%", ($2-$4-$6-$7)/$2*100 }'`

echo "-- $(date -u) --"
echo && echo "  Welcome to $(hostname)"
printf "  -----\n  OS:  %s (%s) [%s : %s]\n" "$OSVR" "$(uname -r)" "$CHAS" "$VIRT"
echo "$LOAD" "$(grep -c 'model name' /proc/cpuinfo)" | \
awk '{ printf "  CPU: %05.2f%% : %05.2f%% : %05.2f%%\n",$1*100/$4, $2*100/$4, $3*100/$4}'
echo "  MEM: $MEMU"
[ -r /etc/sysuse ] && echo "  USE: `cat /etc/sysuse`"
echo && echo "-- ENJOY --"
