#!/bin/bash
# argument is release version

# this is the simulation
cp /extdisk/exp-T.xml .
/opt/netlogo/netlogo-headless.sh --model PROTON-T.nlogo --setup-file exp-T.xml --table table-output.csv > netlogo.log

# now we save both result and experiment file
#https://unix.stackexchange.com/questions/340010/how-do-i-create-sequentially-numbered-file-names-in-bash

today="$( date +"%Y%m%d" )"
number=0
suffix='00'
while test -e "/extdisk/T/$1/$today/$suffix"; do
    (( ++number ))
    suffix="$( printf -- '%02d' "$number" )"
done

dname="/extdisk/T/$1/$today/$suffix"

printf 'Will use "%s" as dirname\n' "$dname"
mkdir -p $dname

cp table-output.csv exp-T.xml netlogo.log $dname
