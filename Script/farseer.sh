#!/bin/sh

LOG_PATH="/Users/Salo/Documents/Farseer/Log"
#LOG_PATH="~/Documents/Farseer/Log/"

mkdir -p $LOG_PATH

if [ "$1" != "-m" ];then
	cd $LOG_PATH

	LAST_LOG=""
	while :
	do
		NEWEST_LOG=$(ls -l | tail -n 1 | awk '{print $9}')
		if [ "$LAST_LOG" != "$NEWEST_LOG" ];then
			LAST_LOG=$NEWEST_LOG
			echo "\n\n\n"
			clear
			echo "\n"
			echo "**************************************************"
			echo "*                                                *"
			echo "*  =============  New Log $(date +%H%M%S)  =============  *"
			echo "*                                                *"
			echo "**************************************************"
			echo "\n" 
			{
				tail -n +0 -f $LAST_LOG
			}&
		fi
		sleep 5
	done
fi
