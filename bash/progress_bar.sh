#!/bin/bash --
#
# Progress bar for the bash script
# Inspired by the Pure Bash Bible
# @Zvk : 2019
#

BAR_LEN=20
MAX_VAL=100

showBar() {
    elapsed=$(($1*$2/100))
    printf -v prog  "%${elapsed}s"
    printf -v total "%$(($2-elapsed))s"
    printf '%s %3s%% \r' "<${prog// /\/}${total}>" "$(($1*100/$3))"
}

sleep() {
  read -rt "$1" <> <(:) || :
}

getTime() {
  for _ in $(seq 2); do f=$f$((RANDOM % 10)); done
  echo 0.$f
}

tput civis
trap "tput cnorm && exit" SIGINT SIGTERM

for ((i=0;i<=$MAX_VAL;i++)); do
  showBar "$i" "$BAR_LEN" "$MAX_VAL"
  sleep $(getTime)
done
printf "\n"

tput cnorm

