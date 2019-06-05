#!/bin/bash

teststring="test"

for idx in $(seq 1 ${#teststring}); do
   echo ${teststring:0:$idx}
   res=$(perl b64_enc.pl ${teststring:0:$idx})
   echo $res
   perl b64_dec.pl $res
   echo -e "\n--------------"
done
