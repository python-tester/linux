#!/bin/sh
read -p "请确定共有的磁盘数量是[b-m]？[Y/N?]" temp
case $temp in
Y|y)
	echo "请输入你要创建的raid类型"
	read raid
	mkfs.btrfs -f -L $raid -d $raid /dev/sd[b-m]1
	sleep 3
	btrfs fi sh
	;;
N|n)
	echo "即将退出"
	sleep 2
	exit 0
	;;
esac
