#!/bin/bash
cd /etc/udev/rules.d/
cp 70-persistent-net.rules 70-persistent-net.rules_bak && rm -rf 70-persistent-net.rules 
reboot
