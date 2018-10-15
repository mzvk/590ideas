#!/bin/bash --
#
# simple shell wrapper ... seems useless ;)
# just to mess around with param. exp. and trap
#
# @MZvk 2018

#provide full path to custom (default) interpreter
cust_interpr="/usr/bin/python"

doshit() { [[ $? -ne 0 ]] && echo "missing interpreter - exit"; }

[[ `which $cust_interpr` ]] || unset cust_interpr
trap "doshit" EXIT
{ wrap_interpr=${INTERPR:-${cust_interpr?}}; } 2> /dev/null
trap "" EXIT

script=$1
shift
exec "$wrap_interpr" "$script" "$@"
