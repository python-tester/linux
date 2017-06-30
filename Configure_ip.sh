配置ip地址的时候，自动化配置脚本，此脚本centos适用
#!/bin/bash
echo "please input eth type [eth0|eth1|eth2|eth3]"
read eth
echo "please input ip"
read ip		
echo "please input gateway"
read gw
echo "HWADDR=`ifconfig | awk '/'$eth'/{print $5}'`" > /etc/sysconfig/network-scripts/ifcfg-$eth
echo "TYPE=Ethernet" >> /etc/sysconfig/network-scripts/ifcfg-$eth
echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-$eth
echo "IPADDR=$ip" >> /etc/sysconfig/network-scripts/ifcfg-$eth
echo "PREFIX=24" >> /etc/sysconfig/network-scripts/ifcfg-$eth
echo "GATEWAY=$gw" >> /etc/sysconfig/network-scripts/ifcfg-$eth
echo "DEFROUTE=yes" >> /etc/sysconfig/network-scripts/ifcfg-$eth
echo "NAME="$eth"" >> /etc/sysconfig/network-scripts/ifcfg-$eth
echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-$eth
#echo "DEFROUTE=yes" >> /etc/sysconfig/network-scripts/ifcfg-$eth
echo "NM_CONTROLLED=no" >> /etc/sysconfig/network-scripts/ifcfg-$eth
service network restart
