#!/bin/bash

version="rp0.8"
NLOGO="/home/mario/NetLogo\ 6.1.1/netlogo-headless_2G.sh" # labss-simul
#NLOGO="/home/paolucci/NetLogo\ 6.1.1/netlogo-headless.sh" # tiny
CPU_FREE=15 # the free cpu needed to launch a new one. For 2-sims, it should mean we have two free processors, so 
# 25% for tiny, 2/32 is 0.06 so maybe 10? 15? 


# checks every ten seconds
wait_until_cpu_free_atleast() {
    awk -v target="$1" 'NR > 3 {print $NF;  if($NF  >= target) { exit(0); }} ' < <(LC_ALL=C mpstat 10 )
 }


for arg in `ls experiments-xml/*rp0.8.[a-z].xml`; do
   wait_until_cpu_free_atleast 25 
   echo $arg $NLOGO
   eval "nohup time " $NLOGO " --model PROTON-T.nlogo --setup-file $arg --table $arg.`hostname`.`git rev-parse --short HEAD`.csv > $arg.`hostname`.`git rev-parse --short HEAD`.out 2>&1 &"
   sleep 600 # it should be long enough to complete a 40k setup
done

