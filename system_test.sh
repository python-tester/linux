#!/bin/bash
#####################################################################
# script by HL                                                      #
# DATE  2017-04-17                                                  #
#####################################################################
Sysinfo()
{
	#check tester
	echo -e -n "Please input your name:"
	read name
	#time synchronization
	#ntpdate pool.ntp.org >> /dev/null
	#hwclock -w
	#check board serial number
	SN=`jzhwinfo|awk 'NR==1{print $4}'| sed 's/^[ \t]*//;s/[ \t]*$//'`
	sleep 0.2
	#check hostname
	hname=`cat /etc/hostname|awk '{print $1}'`
	#check release version
	release=`cat /etc/system-release|awk '{print $3}'|sed 's/^[ \t]*//;s/[ \t]*$//'`
	#check OS and version
	os=`uname -a|awk '{print $3$4}'| sed 's/^[ \t]*//;s/[ \t]*$//'`  
	#check arch
	arch=`uname -m|sed 's/^[ \t]*//;s/[ \t]*$//'`
	#check cpu model
	cname=`cat /proc/cpuinfo|awk -F: '/cpu model/ {print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//'`
	#check detected cpu
	active=`cat /proc/cpuinfo |awk -F: '/detected/{print $2}'|sed 's/\s*//'`
	#check CPU frequency in MHz
	freq=`cat /proc/cpuinfo | awk -F: '/CPU frequency/{printf $2}'|sed 's/^[ \t]*//;s/[ \t]*$//'`
	#check BogoMIPS
	BogoMIPS=`cat /proc/cpuinfo |awk /BogoMIPS/'{printf "%d",$3}'|sed 's/\s*//'`
	#check memory in KB
	temp=`cat /proc/meminfo |awk '/MemTotal/{print $2}'`
	meminfo=`echo "scale=1;$temp/1024/1024" |bc`
	#check LSI mold
	lsi=`lspci|awk '/LSI/{print $11}'|sed 's/^[ \t]*//;s/^[ \t]*$//'`
	#check Ethernet controller 
	ether=`lspci | awk '/Ethernet controller/{printf "|%s",$8}'| sed 's/^[ \t]*//;s/[ \t]*$//'`
	#check usb
	usb=`lsusb|awk '{printf "|%s",$9$11}'|sed 's/^[ \t]*//;s/[ \t]*$//'`
	#startted time
	bdate=`date +"%Y-%m-%d %H:%m:%S"`
	echo -e "Test started on $bdate"| tee -a "$SN"_"$name".log
	#output of result
	echo -e "[1] System Info " | tee -a "$SN"_"$name".log
	echo -e " ----------------- " | tee -a "$SN"_"$name".log
	echo -e " SN	          : $SN" | tee -a "$SN"_"$name".log
	echo -e " Hostname        : $hname" | tee -a "$SN"_"$name".log
	echo -e " Release_Verison : $release"|tee -a "$SN"_"$name".log
	echo -e " OS              : $os" | tee -a "$SN"_"$name".log
	echo -e " Arch            : $arch" | tee -a "$SN"_"$name".log
	echo -e " CPU_model       : $cname " | tee -a "$SN"_"$name".log
	echo -e " CPU_detected    : $active " | tee -a "$SN"_"$name".log
	echo -e " CPU_Frequency   : $freq MHz " | tee -a "$SN"_"$name".log
	echo -e " CPU_BogoMIPS    : $BogoMIPS  " | tee -a "$SN"_"$name".log
	echo -e " Memory          : $meminfo GB" | tee -a "$SN"_"$name".log
	echo -e " LSI             : $lsi " | tee -a "$SN"_"$name".log
	echo -e " Ethernet        : $ether " | tee -a "$SN"_"$name".log
	echo -e " USB             : $usb " | tee -a "$SN"_"$name".log
	echo -e " ----------------- " |tee -a "$SN"_"$name".log
}
HDDinfo()
{
	#output of result
	echo -e "[2]  HDD Info " | tee -a "$SN"_"$name".log
	echo -e "------------- " | tee -a "$SN"_"$name".log
	
	#check backborad
	hnum=`lsblk | awk '/^sd[b-z]/{print $1 }'|wc -l`
	echo -e "\t [2.1] HDD_Total "| tee -a "$SN"_"$name".log
	echo -e "\t HDD_Total  : $hnum " | tee -a "$SN"_"$name".log
	
	#read HDD Model of smartctl
	echo -e "\t [2.2] HDD_Model  "| tee -a "$SN"_"$name".log
	for i in a b c d e f g h i j k l m
  	do
           	hmodel=`smartctl -a /dev/sd$i |awk '/Model/{print $3}'`
		echo -e "\t HDD_Model :$hmodel "|tee -a "$SN"_"$name".log
   	done
	
	#read HDD Serial Number of smartctl
	echo -e "\t [2.4] HDD_Serial "| tee -a "$SN"_"$name".log
	for i in a b c d e f g h i j k l m
  	do
           	hserial=`smartctl -a /dev/sd$i |awk '/Serial/{print $3}'`
           	#printf "%s|" $serial
		echo -e "\t HDD_Serial :$hserial "|tee -a "$SN"_"$name".log
  	done
	
	#read HDD health result
	echo -e "\t [2.5] Smartctl_result "| tee -a "$SN"_"$name".log
	for i in a b c d e f g h i j k l m
        do
                result=`smartctl -a /dev/sd$i |awk -F: '/result/{print $2}'`
                #printf "%s|" $result
		echo -e "\t Smartctl_result  :$result "|tee -a "$SN"_"$name".log
        done
	
	#check HDD size
	echo -e "\t [2.6] HDD_Size "| tee -a "$SN"_"$name".log
	size=`lsblk|awk 'NR==2{printf "|%s",$4} NR>=5{printf "|%s",$4}'`
	echo -e "\t HDD_Size    : $size " | tee -a "$SN"_"$name".log
	echo -e "------------- " | tee -a "$SN"_"$name".log
}
Netinfo()
{
	#read network name
	netname_all=`ifconfig -a |awk '/^eth/{printf "%s ",$1}'`
	#read eth[0-3] Mac
	mac=`ifconfig -a |awk '/eth/{printf "|%s ",$5}'`
	#read eth0 speed
	eth0_speed=`ethtool eth0|awk 'NR==3{printf "%s ",$4} NR==4{printf $1}'`
	#read eth1 speed
	eth1_speed=`ethtool eth1|awk 'NR==3{printf "%s ",$4} NR==4{printf $1}'`
	#read eth2 speed
	eth2_speed=`ethtool eth2|awk 'NR==3{printf "%s ",$4} NR==4{printf $1}'`
	#read eth3 speed
	eth3_speed=`ethtool eth3|awk 'NR==3{printf "%s ",$4} NR==4{printf $1}'`
	#read firmware
	lan_fir=`ethtool -i eth0 |awk -F: '/firmware-version/{print $2}'|sed 's/\s*//'`
	echo -e "[3] Network Info"
	echo -e " ---------------"
	echo -e " Network name  :$netname_all" |tee -a "$SN"_"$name".log
	echo -e " LAN Firmware  :$lan_fir " ||tee -a "$SN"_"$name".log
	echo -e " MAC           :$mac" |tee -a "$SN"_"$name".log
	echo -e " eth0_speed    :$eth0_speed " |tee -a "$SN"_"$name".log
	echo -e " eth1_speed    :$eth1_speed " |tee -a "$SN"_"$name".log
	echo -e " eth2_speed    :$eth2_speed " |tee -a "$SN"_"$name".log
	echo -e " eth3_speed    :$eth3_speed " |tee -a "$SN"_"$name".log
	echo -e "--------------- " | tee -a "$SN"_"$name".log
}

iotest_zfs()
{
	echo -e "[9] IO Test Result "|tee -a "$SN"_"$name".log
	#4k IOPS read
	echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a
	read_iops=`fio -filename=/dev/sdb -direct=0 -iodepth 1 -thread fallocate=0  zero_buffers -rw=randread -ioengine=psync -bs=4k -size=16g -numjobs=30 -runtime=60 -group_reporting -name=mytest|awk '/^[ \t]*read/'|sed 's/^[ \t]*//'|awk -F "[,= ]" '{print $10}'|awk -F "K" '{print $1}'`
	#4k IOPS write
        echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a
	write_iops=`fio -filename=/dev/sdb -direct=0 -iodepth 1 -thread fallocate=0  zero_buffers -rw=randwrite -ioengine=psync -bs=4k -size=16g -numjobs=30 -runtime=60 -group_reporting -name=mytest|awk '/^[ \t]*write/'|sed 's/^[ \t]*//'|awk -F "[,= ]" '{print $9}'|awk -F "K" '{print $1}'`
	#512k IOPS read
	echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a
	read_512=`fio -filename=/dev/sdb -direct=0 -iodepth 1 -thread fallocate=0  zero_buffers -rw=read -ioengine=psync -bs=512k -size=16g -numjobs=30 -runtime=60 -group_reporting -name=mytest|awk '/^[ \t]*read/'|sed 's/^[ \t]*//'|awk -F "[,= ]" '{print $7}'|awk -F "K" '{print $1}'`
	read_MB=`echo "$read_512/1000" |bc`
	#512k IOPS write
	echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a
	write_512=`fio -filename=/dev/sdb -direct=0 -iodepth 1 -thread fallocate=0  zero_buffers -rw=write -ioengine=psync -bs=512k -size=16g -numjobs=30 -runtime=60 -group_reporting -name=mytest|awk '/^[ \t]*write/'|sed 's/^[ \t]*//'|awk -F "[,= ]" '{print $6}'|awk -F "K" '{print $1}'`
	#output of result
	echo -e "\t[9.1] read_iops : $read_iops"|tee -a "$SN"_"$name".log
	echo -e "\t[9.2] read_iops : $read_iops"|tee -a "$SN"_"$name".log
	echo -e "\t[9.3] read      : $read_MB MB/s "|tee -a "$SN"_"$name".log
	echo -e "\t[9.4] write     : $write_MB MB/s "|tee -a "$SN"_"$name".log
}

iotest_btrfs()
{
	echo -e "[9] IO Test Result "|tee -a "$SN"_"$name".log	 
	#4k IOPS read
         echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a
         read_iops=`fio -filename=/dev/sdb -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=4k -size=16g -numjobs=30 -runtime=60 -group_reporting -name=mytest|awk '/^[ \t]*read/'|sed 's/^[ \t]*//'|awk -F "[,= ]" '{print $10}'|awk -F "K" '{print $1}'`
         #4k IOPS write
         echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a
         write_iops=`fio -filename=/dev/sdb -direct=1 -iodepth 1 -thread  -rw=randwrite -ioengine=psync -bs=4k -size=16g -numjobs=30 -runtime=60 -group_reporting -name=mytest|awk '/^[ \t]*write/'|sed 's/^[ \t]*//'|awk -F "[,= ]" '{print $9}'|awk -F "K" '{print $1}'`
         #512k IOPS read
         echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a
         read_512=`fio -filename=/dev/sdb -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=512k -size=16g -numjobs=30 -runtime=60 -group_reporting -name=mytest|awk '/^[ \t]*read/'|sed 's/^[ \t]*//'|awk -F "[,= ]" '{print $7}'|awk -F "K" '{print $1}'`
	 read_MB=`echo "$read_512/1000" |bc`
         #512k IOPS write
         echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a
         write_512=`fio -filename=/dev/sdb -direct=1 -iodepth 1 -thread  -rw=write -ioengine=psync -bs=512k -size=16g -numjobs=30 -runtime=60 -group_reporting -name=mytest|awk '/^[ \t]*write/'|sed 's/^[ \t]*//'|awk -F "[,= ]" '{print $6}'|awk -F "K" '{print $1}'`
	 write_MB=`echo "$write_512/1000" |bc`
         #output of result         
	 echo -e "\t[9.1] read_iops  : $read_iops   "|tee -a "$SN"_"$name".log
	 echo -e "\t[9.2] write_iops : $write_iops  "|tee -a "$SN"_"$name".log
         echo -e "\t[9.3] read       : $read_MB MB/s  "|tee -a "$SN"_"$name".log
	 echo -e "\t[9.4] write      : $write_MB MB/s "|tee -a "$SN"_"$name".log
}
#memory result
chk_memory()
{
	#test memory size
	echo -e "[4] Memory Test Result" | tee -a "$SN"_"$name".log
	echo -e "\t [4.1] Memory size" | tee -a "$SN"_"$name".log
	if [[ $meminfo > 7 ]] && [[ $meminfo < 8 ]]
	then
		echo -e "\t memory size is $meminfo GB,check pass!" | tee -a "$SN"_"$name".log
	else
		echo -e "\t memory size is not 8G,check fail!" | tee -a "$SN"_"$name".log
		exit 1
	fi
	echo -e "\t [4.2] Do Memory stress test for 30s"| tee -a "$SN"_"$name".log
	stressmem=`stress --vm 6 --vm-bytes 1024M -t 30s -v |sed  '/stress: dbug/d'|awk 'NR==2{printf "%s ",$4;printf "%s ",$5;printf "%s ",$6;printf "%s ",$7;printf "%s ",$8}'`
	echo -e "\t result  :$stressmem !"|tee -a "$SN"_"$name".log
	sleep 0.5
}
#cpu result
chk_cpu()
{
	echo -e "[5] CPU Test Result "| tee -a "$SN"_"$name".log
	echo -e "\t [5.1] CPUs detected "| tee -a "$SN"_"$name".log
	#test CPU detected
	if [ $active = 4 ]
	then
		echo -e "\t CPUs detected is  $active ,check pass!" | tee -a "$SN"_"$name".log
	else
		echo -e "\t CPUs detected is not  $active ,check fail!" | tee -a "$SN"_"$name".log
		exit 1
	fi
	echo -e "\t [5.2] CPU Frequency "| tee -a "$SN"_"$name".log
	#test CPU freq
	if [ $freq = 1400.00 ]
	then
		echo -e "\t CPU frequency is $freq MHz ,check pass!" | tee -a "$SN"_"$name".log
	else
		echo -e "\t CPU frequency is not $freq MHz ,check fail!" | tee -a "$SN"_"$name".log
		exit 1
	fi
	echo -e "\t [5.3] CPU BogoMIPS "| tee -a "$SN"_"$name".log
        #test CPU BogoMIPS
        if [ $BogoMIPS > 1500 ] 
        then
                echo -e "\t CPU BogoMIPS is $BogoMIPS ,check pass!" | tee -a "$SN"_"$name".log
        else
                echo -e "\t CPU BogoMIPS is too low ,check fail!" | tee -a "$SN"_"$name".log
                exit 1
        fi
	echo -e "\t [5.4] Do CPU stress test for 30s "|tee -a "$SN"_"$name".log 
	streecpu=`stress -c 100 -v -t 30s |sed  '/stress: dbug/d'|awk 'NR==2{printf "%s ",$4;printf "%s ",$5;printf "%s ",$6;printf "%s ",$7;printf "%s ",$8}'`
	echo -e "\t result :$streecpu !"|tee -a "$SN"_"$name".log
	sleep 0.5
}
#Network result	
chk_net()
{
	echo -e "[6] Network Test Result "| tee -a "$SN"_"$name".log
	echo -e "\t [6.1] Network Name  "| tee -a "$SN"_"$name".log
	#test network name
	netname_eth0=`ifconfig -a |awk '/eth0/{printf "%s ",$1}'|sed 's/\s*$//'`
	if [ $netname_eth0 = "eth0" ]
	then
		echo -e "\t Network name is from eth0 to eth3,check pass!"|tee -a "$SN"_"$name".log
	else
		echo -e "\t Network name is not from eth0 to eth3,check fail!"|tee -a "$SN"_"$name".log
		exit 1
	fi
	#test mac
	echo -e "\t [6.2] MAC  "| tee -a "$SN"_"$name".log
	mac_eth0=`ifconfig -a |awk '/eth0/{printf "%s ",$5}'|sed 's/\s*$//'|cut -d ":" -f 1-5`
	mac_eth1=`ifconfig -a |awk '/eth1/{printf "%s ",$5}'|sed 's/\s*$//'|cut -d ":" -f 1-5`
	mac_eth2=`ifconfig -a |awk '/eth2/{printf "%s ",$5}'|sed 's/\s*$//'|cut -d ":" -f 1-5`
	mac_eth3=`ifconfig -a |awk '/eth3/{printf "%s ",$5}'|sed 's/\s*$//'|cut -d ":" -f 1-5`
	if [[ $mac_eth0 = $mac_eth1 ]] && [[ $mac_eth1 = $mac_eth2 ]] && [[ $mac_eth2 = $mac_eth3 ]]
	then
		echo -e "\t MAC address is right ,check pass!"|tee -a "$SN"_"$name".log
	else
		echo -e "\t MAC address is not right,check fail!"|tee -a "$SN"_"$name".log
		exit 1
	fi
	#test firmware
	echo -e "\t [6.3] LAN Firmware  "| tee -a "$SN"_"$name".log
	exp_lan_ver="1.16.26.0, TP 0.1.4.9"
	firmware=`ethtool -i eth0 |awk -F: '/firmware-version/{print $2}'|sed 's/\s*//'`
	if [ "$firmware" = "$exp_lan_ver" ]
	then
		echo -e "\t LAN FW is $firmware,check pass!" | tee -a "$SN"_"$name".log
	else
		echo -e "\t LAN FW is not $exp_lan_ver,check fail!" | tee -a "$SN"_"$name".log
		exit 1
	fi
}

chk_os()
{
	echo -e " [7] OS Test Result "| tee -a "$SN"_"$name".log
	echo -e "\t [7.1] OS Version  "| tee -a "$SN"_"$name".log
	os_name=`uname -r`
	if [ "$os_name" = "3.10.0-apollo" ]
	then
		echo -e "\t OS Version is $os_name,check pass!"| tee -a "$SN"_"$name".log
	elif [ "$os_name" = "3.8.0-Hypersion_v3.2" ]
	then
		echo -e "\t OS Version is $os_name,check pass!"| tee -a "$SN"_"$name".log
	else
		echo -e "\t OS Verison is not right,check fail!"| tee -a "$SN"_"$name".log
		exit 1
	fi

}
chk_pci()
{
	echo -e "[8] RAID Card Test Result "| tee -a "$SN"_"$name".log
	echo -e "\t [8.1] Card Location  "| tee -a "$SN"_"$name".log
	loca_all=`lspci |awk '/^0001/{print $1}'`
	loca=`lspci |awk -F: '/^0001/{print $1}'|sed 's/\s*$//'`
	if [ "$loca" =  "0001" ]
	then
		echo -e "\t RAID Card Location is $loca_all,check pass!" | tee -a "$SN"_"$name".log

	else
		echo -e "\t RAID Card Location is not $loca_all,check fail!" | tee -a "$SN"_"$name".log
		exit 1
	fi
	
}
clear
echo -n -e "本次测试是否包含性能测试(Y/N):"
read choice
case $choice in
	Y|y)
		echo -e -n "请确认文件系统类型是否是ZFS文件系统(Y/N): "
		read tmp
		if [ $tmp = "Y" ] || [ $tmp = "y" ]
		then
			Sysinfo;HDDinfo;Netinfo;chk_memory;chk_cpu;chk_net;chk_os;chk_pci;iotest_zfs	
		else
			Sysinfo;HDDinfo;Netinfo;chk_memory;chk_cpu;chk_net;chk_os;chk_pci;iotest_btrfs
		fi
		;;
	N|n)
		Sysinfo;HDDinfo;Netinfo;chk_memory;chk_cpu;chk_net;chk_os;chk_pci
		;;
esac

echo ""
echo -e "====================================================================" |tee -a "$SN"_"$name".log
echo -e "--------------------------------------------------------------------" |tee -a "$SN"_"$name".log
echo -e ""
echo -e "          PP PP          AA          SSSSSSS     SSSSSSS      " |tee -a "$SN"_"$name".log
echo -e "         PP    PP      AA  AA       SS          SS            " |tee -a "$SN"_"$name".log
echo -e "         PP     PP    AA    AA      SS          SS            " |tee -a "$SN"_"$name".log
echo -e "         PP PP PP    AA AAAA AA      SSSSSSS     SSSSSSS      " |tee -a "$SN"_"$name".log 
echo -e "         PP          AA      AA           SS          SS      " |tee -a "$SN"_"$name".log 
echo -e "         PP          AA      AA           SS          SS      " |tee -a "$SN"_"$name".log
echo -e "         PP          AA      AA     SSSSSSS     SSSSSSS       " |tee -a "$SN"_"$name".log
echo -e "" |tee -a "$SN"_"$name".log
echo -e "--------------------------------------------------------------------" |tee -a "$SN"_"$name".log
echo -e "====================================================================" |tee -a "$SN"_"$name".log
					
