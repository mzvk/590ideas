#!/usr/bin/bash

# MZvk|A544778

ifExist(){
  result=$(mysql -u root -p$1 radius -t <<< 'select * from radcheck where username="'$2'"' 2>/dev/null)
  [[ -z $result ]] && echo "[!!] User $user not in DB"
}

option=0
if [ $# -lt 1 ]; then
  option=1
fi
while getopts ":a:r:c:l" opt; do
  case "${opt}" in
    l) ((option|=1));;
    a|r|c) [[ -z "$user" ]] && user=$OPTARG && optdo=$opt || echo "> Add/Remove/Check are exclusive, ignoring \"-$opt $OPTARG\".";;
    /?) ;;
  esac
done
shift $((OPTIND - 1))

if [[ $((option&1)) == 1 && -z "$optdo" ]]; then
 read -sp "Please provide password for root user in mysql: " pass; echo -e "\nResponse from SQL:"
 mysql -u root -p$pass radius -t  <<< 'select * from radcheck' 2>/dev/null
fi

if [[ -n $optdo ]]; then
  user=$(echo ${user//[:-]} | tr '[A-Z]' '[a-z]')
  if [[ $user =~ ^[a-f0-9]{12}$ ]]
   if [[ -z $pass ]]; then
     read -sp "Please provide password for root user in mysql: " pass; echo
   fi
   then
    case "${optdo}" in
      r) [[ -z $(ifExist $pass $user) ]] &&
         mysql -u root -p$pass radius -t  <<< 'delete from radcheck where username="'$user'"' 2>/dev/null &&
         echo "> User $user removed from DB" ||
         echo "> User $user not in DB";;
      a) [[ -n $(ifExist $pass $user) ]] &&
         mysql -u root -p$pass radius -t  <<< 'insert into radcheck (username, attribute, op, value) values ("'$user'", "Auth-Type", ":=", "Accept")' 2>/dev/null &&
         echo "> User $user added to DB" ||
         echo "> User $user already in DB";;
      c) ifExist $pass $user
    esac
    (((option&1)==1)) && echo -e "\nResponse from SQL: " && mysql -u root -p$pass radius -t  <<< 'select * from radcheck' 2>/dev/null
  else
    echo "> Incorrect MAC address [$user]"
  fi
fi

