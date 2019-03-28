#!/bin/bash --
#
# Quick tail&test to show parameter expansion
# @Zvk : 2019
#

read -p "Wanna go nuts? (y|N): " choice
[[ $choice =~ ^[YNyn]([Ee][Ss]|[Oo])?$ ]] && choice=${choice:0:1} || unset choice
choice=${choice:-n}

case $choice in
   y) echo -e "Yes, I wanna go \033[31mberserk!!\033[0m";;
   n) echo -e "No I'm cool.";;
esac
