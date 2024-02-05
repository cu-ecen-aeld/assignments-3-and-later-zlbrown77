#!/bin/bash

if [ -z "$1" ] # 1 is directory
then
	echo "Path input blank $1"
	exit 1
fi

if [ -x "$2" ] # 2 is text string
then 
	echo "Text string input blank"
	exit 1
fi

if [ ! -d "$(dirname "$1")" ] #see if directory exists
then
	echo "$1 does not exist. Creating directory and file"
	mkdir -p "$(dirname "$1")"
	#mkdir -p "$(dirname "/home/zlbrown77/test1/test.txt")"
	rm -f -- $1
	touch $1
	echo "$2" >> $1
else
	echo "creating directory and file"
	rm -f -- $1
	touch $1
	echo "$2" >> $1
fi

if [ ! -d "$(dirname "$1")" ] #check if file was made
then
	echo "Failed to create file" 
	exit 1
fi


