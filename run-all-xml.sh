#!/bin/bash

version="rp0.8"
netlogo="/Applications/NetLogo\ 6.0.4/netlogo-headless.sh"

for arg in `ls experiments-xml/*rp0.8.xml`; do
   eval "$netlogo --model PROTON-T.nlogo --setup-file $arg --table $arg.csv > $arg.out 2>&1 &"	
done
