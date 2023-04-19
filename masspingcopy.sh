#!/bin/bash

argc=$#
if [ $# -lt 1 ]
then
   echo "Usage: $0 <ip-list-file>"
   exit 1
fi

hosts=$1
function customping
{
  FLAG=/home/ubuntu/downfile.txt
  SUBJECT="Ping failed $1"
  ping -c 1 -W 1 "$1" >/dev/null 2>&1 && (echo "$1 is up";sed -i "/$1/d" $FLAG) || if grep -n $1 $FLAG
	then 
	  return
	else 
	  (echo "Host : $1 is down (ping failed) at $(date)" | mail -s "$SUBJECT" YOUR_EMAIL | echo "$1 is down"; echo $1 >> $FLAG) 
	fi
#  sleep 0.01s
}


DEFAULT_NO_OF_PROC=8
noofproc=$DEFAULT_NO_OF_PROC

if [ -n "$2" ] #user-set no. of process instead of default
then
  noofproc=$2
  echo "Max processes: $noofproc"
fi

while true
do
  echo ''
  date +%H:%M:%S
  export -f customping && cat "$hosts" | xargs -n 1 -P "$noofproc" -I{} bash -c 'customping {}' \;
  sleep 1

done
