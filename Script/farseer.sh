#!/bin/sh

logpath="/Users/Salo/Documents/Farseer/Log/"
cd $logpath
filename=$(ls -l | tail -n 1 | awk '{print $9}')
tail -f $filename
