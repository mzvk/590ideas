#!/bin/bash

TXT="\_Detected sudo using:\e[31m"

if [[ $EUID -eq 0 ]]; then
  echo -e "Run with \e[31mroot\e[0m privileges"
  if [[ $SUDO_COMMAND == "$0" ]]; then echo -e $TXT "\$SUDO_COMMAND\e[0m"; fi
  if [[ -n `ps -ef | grep "sudo $0$"` ]]; then echo -e $TXT "processes\e[0m"; fi
fi

echo "Script $0 executed..." && exit
