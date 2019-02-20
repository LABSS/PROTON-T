#!/bin/bash
# argument is release version

# this is the simulation
cp /extdisk/exp-T.xml .
/opt/netlogo/netlogo-headless.sh --model PROTON-T.nlogo --setup-file exp-T.xml --table table-output.csv

# now we save both result and experiment file
#https://unix.stackexchange.com/questions/340010/how-do-i-create-sequentially-numbered-file-names-in-bash

today="$( date +"%Y%m%d" )"
number=0

while test -e "/extdisk/$1/$today$suffix"; do
    (( ++number ))
    suffix="$( printf -- '-%02d' "$number" )"
done

dname="$today$suffix"

printf 'Will use "%s" as dirname\n' "$dname"
mkdir -p "/extdisk/T/$1/$today$suffix/"

cp table-output.csv "/extdisk/T/$1/$today$suffix/"
cp exp-T.xml "/extdisk/T/$1/$today$suffix/"

