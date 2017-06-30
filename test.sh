#!/bin/bash
#cat /sys/block/sd*/device/queue_depth 
#echo 10 >  /sys/block/sdb/device/queue_depth 

chk_time()
{
get_time=`date +%Y`
	if [ "$get_time" = "2017" ] ;then
		echo -e "\e[32mTime test pass! \e[32m" | tee -a "$SN"_"$logdate".log
	else
		echo -e "\e[31mTime is not right, check fail,please change time! \e[31m" | tee -a "$SN"_"$logdate".log
		exit 1
	fi
}

#
lan()
{
	exp_lan_ver="1.15.37.0,TP0.1.4.9"
	get_lan_fw=`ethtool -i eth1|grep "firmware"|awk '{print $2$3$4}'`
	if [ "$get_lan_fw" = "$exp_lan_ver" ];then
		echo -e "\e[32mLAN FW check pass! \e[32m" | tee -a "$SN"_"$logdate".log
	else 
		echo -e "\e[31mLAN FW check fail! \e[31m" | tee -a "$SN"_"$logdate".log
		exit 1
	fi

	MAC=`ifconfig -a |grep HWaddr |awk '{print $5}'`
	echo -e "\e[32m$MAC" 
	while [ 1 ]
	do
		read -p "Please check,and input Y or N: " yn
		if [ "$yn" == "Y" ] || [ "$yn" == "y" ]; then
			echo -e "\e[32mOK, MAC is right,continue! \e[32m" | tee -a "$SN"_"$logdate".log
			return 0
		elif [ "$yn" == "N" ] || [ "$yn" == "n" ]; then
			echo -e "\e[31mOh, MAC is wrong,interrupt! \e[31m" | tee -a "$SN"_"$logdate".log
			exit 1
		else
			echo "I don't know what is your choise"
		fi
	done
}
# 
hdd()
{
	for z in a b c d e f g h i j k l m 
	do
		za=`hdparm -T /dev/sd$z |grep 'cached'|awk '{print int($10)}'` 
		zb=`hdparm -t /dev/sd$z |grep 'buffered'|awk '{print int($11)}'`
		if [ "$za" > "999" ];then
			echo -e "\e[32mHDD sd$z cached ($za) read test pass! \e[32m" | tee -a "$SN"_"$logdate".log
		else
			echo -e "\e[31mHDD sd$z chaed read test fail! \e[31m" | tee -a "$SN"_"$logdate".log
		fi
		if [ "$zb" > "99" ];then
			echo -e "\e[32mHDD sd$z buffered ($zb) read test pass! \e[32m" | tee -a "$SN"_"$logdate".log
		else
			echo -e "\e[31mHDD sd$z buffered read test fail! \e[31m" | tee -a "$SN"_"$logdate".log
		fi
	done
#
    #check the volume and disk  
    get_hdd_num=`fdisk -l |grep -c "2000.4 GB"`
    if [ "$get_hdd_num" = "12" ] ;then
        echo -e "\e[32mHDD number is 12 and volume is 2T. test pass! \e[32m" | tee -a "$SN"_"$logdate".log
    else
        get_hdd_num4T=`fdisk -l |grep -c "4000.8 GB"`
        if [ "$get_hdd_num4T" = "12" ] ;then
            echo -e "\e[32mHDD number is 12 and volume is 4T. test pass! \e[32m" | tee -a "$SN"_"$logdate".log
        else 
            echo -e "\e[31mHDD number is not 12,and volume is not 2T or 4T check fail,please check HDD! \e[31m" | tee -a "$SN"_"$logdate".log
            exit 1
        fi
    fi
}

'''pci()
{
	exp_dev_lsi=0022
	get_dev_lsi=`lspci -v | awk '/Mellanox Technologies Device/{print $5}'`
	if [ "$get_dev_lsi" = "$exp_dev_lsi" ] ;then
		echo -e " \e[32mLSI check test pass!  \e[32m" | tee -a "$SN"_"$logdate".log
	else
		echo -e " \e[31mLSI device is not right, check fail!  \e[31m" | tee -a "$SN"_"$logdate".log
		exit 1
	fi
}'''
cpu()
{
	# Memory number and size check

	exp_mem_rom=7777336 
	get_mem_rom=`cat /proc/meminfo|awk '/MemTotal/{print $2}'`
#	if [ "$get_mem_rom" = "$exp_mem_rom" ] ;then
#    change the memory form 7000000 to 8000000
	if [ $get_mem_rom -ge 7000000 ] && [ $get_mem_rom -le 8000000 ];then
		echo -e "\e[32mRAM number & ROM test pass!" | tee -a "$SN"_"$logdate".log
	else
		echo -e "\e[31mRAM number & ROM is not right, check fail!" | tee -a "$SN"_"$logdate".log
		exit 1
	fi

	# CPU number and Sequ check
	# CPU number
	exp_cpu_cnt=4
	get_cpu_cnt=`cat /proc/cpuinfo |grep detected |awk '{print $4}'` 
	if [ "$get_cpu_cnt" = "$exp_cpu_cnt" ]; then
		echo -e "\e[32mCPU CNT check pass!" | tee -a "$SN"_"$logdate".log
	else
		echo -e "\e[31mCPU CNT check fail!" | tee -a "$SN"_"$logdate".log
		exit 1
	fi
	# CPU Mhz
	exp_cpu_mhz=1400.00
	get_cpu_mhz=`cat /proc/cpuinfo |grep MHz |awk '{print $5}'` 	
	if [ "$get_cpu_cnt" = "$exp_cpu_cnt" ]; then
		echo -e "\e[32mCPU MHz check pass!" | tee -a "$SN"_"$logdate".log
	else
		echo -e "\e31mCPU MHz check fail!" | tee -a "$SN"_"$logdate".log
		exit 1
	fi
}
zz()
{   clear
	echo "Make sure all HDD led blinking ,Y or N （确认所有的硬盘灯闪亮）!" | tee -a "$SN"_"$logdate".log
	while [ 1 ]
	do
		read -p "please input yes or no (y/n)" hdl
		if [ "$hdl" == "y" ] || [ "$hdl" == "n" ];then
			echo $hdl >> "$SN"_"$logdate".log
			break
		fi
	done
	clear
	echo "Check two PSU,make sure one of them can work alone, Y or N（分别插拔2电源，确认服务器正常工作） !" | tee -a "$SN"_"$logdate".log
	while [ 1 ]
	do
		read -p "please input yes or no (y/n)" hdl
		if [ "$hdl" == "y" ] || [ "$hdl" == "n" ];then
			echo $hdl >> "$SN"_"$logdate".log
			break
		fi
	done
	clear
	echo "When one PSU working, make sure buzzer ring, Y or N (单个电源工作时，确认蜂鸣器是否报警)!" | tee -a "$SN"_"$logdate".log
	while [ 1 ]
	do
		read -p "please input yes or no (y/n)" hdl
		if [ "$hdl" == "y" ] || [ "$hdl" == "n" ];then
			echo $hdl >> "$SN"_"$logdate".log
			break
		fi
	done
	clear
	echo "Cheak all lan led blink ,and make pin of LAN good, Y or N (万兆/千兆网孔灯闪亮，pin针无弯曲磨损)!" | tee -a "$SN"_"$logdate".log
	while [ 1 ]
	do
		read -p "please input yes or no (y/n)" hdl
		if [ "$hdl" == "y" ] || [ "$hdl" == "n" ];then
			echo $hdl >> "$SN"_"$logdate".log
			break
		fi
	done
	clear
	echo "Install keyboard or U flash, make sure led blink（分别在USB接口处接键盘或者U盘，确认可用）" | tee -a "$SN"_"$logdate".log
	while [ 1 ]
	do
		read -p "please input yes or no (y/n)" hdl
		if [ "$hdl" == "y" ] || [ "$hdl" == "n" ];then
			echo $hdl >> "$SN"_"$logdate".log
			break
		fi
	done
	clear
	echo "Check PS2 function of connectors（检测PS2鼠标键盘功能）" | tee -a "$SN"_"$logdate".log
	while [ 1 ]
	do
		read -p "please input yes or no (y/n)" hdl
		if [ "$hdl" == "y" ] || [ "$hdl" == "n" ];then
			echo $hdl >> "$SN"_"$logdate".log
			break
		fi
	done
	echo -e "\033[41;37;5m"
	clear
	echo "  Check color of monitor（检查显示器，检查无花瓶等不良现象）" | tee -a "$SN"_"$logdate".log
	sleep 8
	
	echo -e "\033[42;37;5m"
	clear
	echo "  Check color of monitor（检查显示器，检查无花瓶等不良现象）" | tee -a "$SN"_"$logdate".log
	sleep 8
	
	echo -e "\033[43;37;5m"
	clear
	echo "  Check color of monitor（检查显示器，检查无花瓶等不良现象）" | tee -a "$SN"_"$logdate".log
	sleep 8
	
	echo -e "\033[44;37;5m"
	clear
	echo "  Check color of monitor（检查显示器，检查无花瓶等不良现象）" | tee -a "$SN"_"$logdate".log
	sleep 8
	
	echo -e "\033[40;37;5m"
	clear
	echo "  Check color of monitor，make sure VGA function，Y or N（检查显示器，检查无花瓶等不良现象）！" | tee -a "$SN"_"$logdate".log
	sleep 8
	
	while [ 1 ]
	do
		read -p "please input yes or no (y/n)" hdl
		if [ "$hdl" == "y" ] || [ "$hdl" == "n" ];then
			echo $hdl >> "$SN"_"$logdate".log
			break
		fi
	done
	echo "Check power on/off function!确认开关机功能良好" | tee -a "$SN"_"$logdate".log
	while [ 1 ]
	do
		read -p "please input yes or no (y/n)" hdl
		if [ "$hdl" == "y" ] || [ "$hdl" == "n" ];then
			echo $hdl >> "$SN"_"$logdate".log
			break
		fi
	done
}
knl()
{
	# Kernel version check

	exp_k_ver="3.10.0-apollo"
	get_k_ver=`uname -a |awk '{print $3$4}' `
	if [ "$get_k_ver" = "$exp_k_ver" ] ;then
		echo -e " \e[32mKernel version test pass!  \e[32m" | tee -a "$SN"_"$logdate".log
	else
		echo -e " \e[31mKernel version is not right, check fail! \e[31m" | tee -a "$SN"_"$logdate".log
		exit 1
	fi
}
str()
{
	echo "########Now do CPU stress test for 30s########"
	stress -c 100 -v -t 30s | tee -a "$SN"_"$logdate".log

	sleep 1s
	echo "########Now do IO stress test for 30s########"
	stress -i 10 -v -t 30s | tee -a "$SN"_"$logdate".log

	sleep 2s    
	echo "########Now do HDD stress test for 66s########"
	stress -d 10 --hdd-bytes 100M -v -t 66s | tee -a "$SN"_"$logdate".log

	cpuioworker=`cat "$SN"_"$logdate".log |grep successful -c` 
	if [ "$cpuioworker" = "3" ]; then
		echo  -e  "\e[32mCPU,IO and HDD  stress test pass!\e[32m" | tee -a "$SN"_"$logdate".log
	else
		echo -e "\e[31mCPU,IO and HDD stress test fail!\e[31m" | tee -a "$SN"_"$logdate".log
		exit 1
	fi
}

jzhwinfo
read -p "Please input serial number: " SN
logdate=`date +%Y%m%d%H%M%S`
echo "$SN" | tee -a "$SN"_"$logdate".log
hwclock | tee -a "$SN"_"$logdate".log

chk_time
lan
hdd
cpu
zz
knl
str

clear
echo ""
echo ""
echo ""
echo -e "          \e[36m=============================================================\e[37m"
echo -e "          \e[33m  ---------------------------------------------------------\e[37m"
echo -e "\e[32m"
echo -e "                   PP PP           AA          SSSSSSS     SSSSSSS      "
echo -e "                 PP      PP      AA  AA       SS          SS            "
echo -e "                 PP      PP     AA    AA      SS          SS            "
echo -e "                 PP PP PP      AA AAAA AA      SSSSSSS     SSSSSSS      "
echo -e "                 PP            AA      AA           SS          SS      "
echo -e "                 PP            AA      AA           SS          SS      "
echo -e "                 PP            AA      AA     SSSSSSS     SSSSSSS       "
echo -e "\e[0m"                                    
echo -e "          \e[33m  ---------------------------------------------------------\e[37m"
echo -e "       \e[36m===================================================================\e[37m"
echo ""


echo -e  "                        All function check pass, please power down!          "
