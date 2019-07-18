#!/bin/bash --
#
# Script to generate float number
# @MZvk: 2019
#

usage() {
  echo -e "Script usage: $0 float_precision\n * float_precision: 1 - 10" && exit 0
}

[[ $# -eq 0 ]] && usage
[[ $1 =~ ^([1-9]|10)$ ]] && prec=$1

for _ in $(seq $prec); do
  f=$f$((RANDOM % 10));
done

echo 0.$f
