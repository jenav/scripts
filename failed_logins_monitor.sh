#!/usr/bin/env bash

sudo lastb > lastb.log

desde=$(tail -n 1 lastb.log | awk '{$1=""; $2=""; sub("  ", " "); print}')

intentos=$(wc -l lastb.log | awk '{ print $1 }')
(( intentos-=2 ))

echo "Intentos fallidos de login desde '${desde:1}': ${intentos}"

cat lastb.log | awk '{ print $3 }' > .lastb.tmp
sort .lastb.tmp | uniq  | head -n -4 | tail -n +2 > .lastb.tmp_2

while read in; do 
   todo=$(curl -s "ipinfo.io/${in}")
   pais=$(echo "${todo}" | jq -r '.country')
   region=$(echo "${todo}" | jq -r '.region')
   org=$(echo "${todo}" | jq -r '.org')
   country=$(./country "${pais}")
   echo -e "${in} -> {\n\t country: \"${country}\",\n\t region: \"${region}\",\n\t org: \"${org}\"\n}"; 
   #echo "${in} -> $(curl -s "ipinfo.io/${in}" | jq '. | {country: .country, region: .region, org: .org}')"
done < .lastb.tmp_2

rm .lastb.tmp
rm .lastb.tmp_2
