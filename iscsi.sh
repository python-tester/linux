iscsiadm -m discovery -t sendtargets -p 10.1.1.53:3260 
iscsiadm -m node -T iqn.2016-01.node0:raid0iscsi  -p 10.0.0.40:3260 -l
fdisk    –l
#mkfs.xfs -f /dev/sdb
#mount /dev/sdb /mnt

iscsiadm  -m session
查看现有iqn

退出当前iqn
iscsiadm -m node -U all
退出当前iqn

iscsiadm -m node -o delete -T LUN_NAME -p ISCSI_IP

删除iscsi发现记
删除iscsi发现记录

断开连接
 iscsiadm -m node -T iqn.2014-05.cn.vqiu:datastore.public -p 192.168.109.238:3260 -u