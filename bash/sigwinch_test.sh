#!/bin/bash

wnd_update() {
   echo -e "\033[H\033[Jwindow changed $((c++)) time(s)!"
}

c=1
trap 'wnd_update' SIGWINCH
while :; do :; done
