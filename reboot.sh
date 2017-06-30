#!/bin/bash
SN=`jzhwinfo |awk -F: 'NR==1{print $2}'|sed 's/\s*//'`
date >> $SN-reboot.log
cat $SN-reboot.log|grep "2017"|wc -l >> $SN-reboot.log
reboot
