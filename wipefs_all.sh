#!/bin/sh
btrfs fi sh
read -p "你确定要删除Raid么 [Y/N]?" answer
case $answer in
Y|y)
	DEVICELIST=`btrfs fi sh |grep path |awk '{printf "%s ",$8}'`
	for i in $DEVICELIST
	do
		wipefs -a $i
	done
	;;
N|n)
	echo '即将退出'
	sleep 2
	exit 0
	;;
esac
