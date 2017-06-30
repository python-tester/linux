#!/bin/bash
for i in b c d e f g h i j k l m
do 
	parted /dev/sd${i}  rm 1  > /dev/null 2>&1
	parted /dev/sd${i}  mklabel gpt  y  > /dev/null 2>&1
	parted /dev/sd${i}   << EOF 
mkpart ext4 0% 100%
quit
EOF
done


