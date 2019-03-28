#!/bin/bash --
#
# Workaround to fix problem on VMs hosted on esxi, when all NICs
# above first disappeared. For me only reload of used modules helped,
# but still I don't know root cause of the problem
# Script checks what drivers are used by NICs and reloads them.
# @Zvk : 2018
#

## To install:
## create a file - fixeth.service - in /etc/systemd/system/
###################################
## file content:
## [Unit]
## Description=Reloads Ethernet drivers
## After=network.target
##
## [Service]
## Type=oneshot
## ExecStart=/etc/fix_eth.sh
##
## [Install]
## WantedBy=multi-user.target
###################################
## Then:
## systemctl daemon-reload
## systemctl enable fixeth.service

regex="Kernel driver in use: (\w+)"
modules=()

mapfile -t eth < <(lspci -nn | grep 'Ethernet')
for pci in "${eth[@]}"; do
  pci=$(echo $pci | grep -oE "[0-9a-f]{4}:[0-9a-f]{4}")
  [[ $(lspci -d $pci -v) =~ $regex ]] && modules+=(${BASH_REMATCH[1]})
done

mapfile -t modules < <(echo "${modules[*]}" | tr ' ' '\n' | sort -u)
for mod in "${modules[@]}"; do
  modprobe -r $mod
  modprobe $mod
done
