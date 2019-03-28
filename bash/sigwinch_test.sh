#!/bin/bash --
#
# simple script to test trapping SIGWINCH signal
# @MZvk: 2019
#

wnd_update() {
   echo -e "\033[H\033[Jwindow changed $((c++)) time(s)!"
}

trap 'wnd_update' SIGWINCH

c=1
while :; do :; done
