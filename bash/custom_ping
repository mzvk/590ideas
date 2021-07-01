#!/bin/bash -

SLPTIME=5
HOSTS=()

trap int_exit INT
stty -echoctl

function int_exit() {
    stty echoctl
    tput cnorm
    echo -e "\nCLEAN EXIT"
    exit
}

if [[ $# -lt 1 ]]; then echo "NO HOST FILE PROVIDED"; exit 1; fi
if command -v ping &>/dev/null; then cmd='ping -c1 -q '; fi
if [ -z ${cmd+.} ]; then echo "NO SUITABLE PING COMMAND FOUND FOR HOST PROBING"; exit; fi 
for file in "$@"; do
    if test -f $file; then
        while IFS= read -r line; do
            if [[ $line =~ ^# ]]; then echo -e "> HOST \033[32m${line:1}\033[0m IGNORED"; else HOSTS+=($line); fi
        done < $file
    else echo -e "\033[91m[ERROR] FILE $file DOES NOT EXISTS\033[0m"
    fi
done

tput civis && echo
while :
do 
    DEAD=()
    ALIVE=()
    cursr=0
    for host in "${HOSTS[@]}"; do
        cursr=$((cursr+1))
        printf 'PROBING HOSTS [%4d/%4d]%s\r' $cursr ${#HOSTS[@]} $(printf ' %.0s' {1..10})
        if $cmd $host &>/dev/null; then
            ALIVE+=($host)    
        else
            DEAD+=($host)
        fi
    done
    printf "\033[32m:: %s :: SWEEP RESULT: %d/%d (%d%%)\033[0m\n" "$(date +"%d.%m.%Y %H:%M:%S")" ${#ALIVE[@]} ${#HOSTS[@]} $((${#ALIVE[@]}*100/${#HOSTS[@]})) 
    if (( ${#DEAD[@]} )); then
        for host in "${DEAD[@]}"; do
            echo -e " * $host is \033[91munreachable\033[0m"
        done
    fi
    for i in $(seq 0 $((SLPTIME-1))); do
        printf 'SLEEP STATE (%ds)%s\r' $((SLPTIME-i)) $(printf ' %.0s' {1..20})
        sleep 1
    done
done
int_exit()
