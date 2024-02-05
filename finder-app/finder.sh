#!/bin/bash



#read -p "Enter filesdir and searchstr" filesdir searchstr


if [ -z "$1" ]
then
	echo "Filesdir input blank $1"
	exit 1
fi

if [ -x "$2" ]
then 
	echo "Seachstr input blank"
	exit 1
fi

if [ ! -d "$1" ] 
then
	echo "$1 does not exist."
	exit 1
fi

filenum=$(find $1 -type f | wc -l)
	
linematch=$(grep -Rni $2 $1 | wc -l)
	

echo "The number of files are $filenum and the number of matching lines are $linematch"


