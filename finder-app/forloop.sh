#!/bin/sh

NUMFILES=10
WRITESTR=AELD_IS_FUN
WRITEDIR=/home/zlbrown77/test1/aeld-data
username=$(cat conf/username.txt)

for i in $( seq 1 $NUMFILES)
do
	./writer "$WRITEDIR/${username}$i.txt" "$WRITESTR"
	echo "$WRITEDIR/${username}$i.txt writing $WRITESTR"
done
echo "success"
