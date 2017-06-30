#定时重启脚本
#!/bin/bash
cp /bin/vi /usr/bin
cd /var/spool/cron/ && echo "*/4 * * * * sh /root/reboot.sh" >> /var/spool/cron/root
