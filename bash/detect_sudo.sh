#!/bin/bash --
#
# detects if command was initiated with sudo
# propably works only on bash and not for all POSIX shells
# @Zvk : 2017
#

txt="+ Detected sudo using:\e[31m"

if [[ $EUID -eq 0 ]]; then
  echo -e "Run with \e[31mroot\e[0m privileges"
  [[ $SUDO_COMMAND =~ ($BASH )?$0$ ]] && echo -e $txt "\$SUDO_COMMAND\e[0m"
  [[ -n `ps -ef | grep "sudo .*$0$"` ]] && echo -e $txt "processes\e[0m"
fi

echo "Script $0 executed..." && exit
