#!/bin/bash

version="rp0.8"
netlogo="NetLogo\ 6.1.1/netlogo-headless4_G.sh"

for arg in `ls experiments-xml/*rp0.8.xml`; do
   eval "nohup time '"$NLOGO"' --model PROTON-T.nlogo --setup-file $arg --table $arg.`hostname`.`git rev-parse --short HEAD`.csv > $arg.`hostname`.`git rev-parse --short HEAD`.out 2>&1 &"
done
