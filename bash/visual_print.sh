#!/bin/bash --

wcnt=0
skip=5

function ehand {
   tput cnorm
   exit
}

function char {
   (( $1 == 92 )) && set -- $(($1 + 1))
   printf \\$(printf '%03o' $1)
}

trap ehand EXIT INT
tput civis

[[ -z $* ]] && { echo "You must specify input text file."; exit; }

while read line; do
   out=""
   while :; do
      (( $wcnt > $skip )) && { wcnt=0; out+=${line::1}; line=${line:1}; } || ((wcnt++))
      [[ -z $line ]] && echo -en "$out\n" && break
      sleep 0.02
      echo -en "$out\033[100m$(char $(($RANDOM % 93 + 33)))\033[0m\r"
   done;
done < $1
