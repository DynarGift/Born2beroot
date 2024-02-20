#!/bin/bash

echo "============================================================================="
echo "            System Monitoring (Running: $(date +"%D || %H:%M:%S"))           "
echo "============================================================================="
echo -e
#--------------------Architecture-------------------------------------------------------------------

arch=$(uname -a)
echo "#Architecture: $arch"

#--------------------Physical CPU-------------------------------------------------------------------

pCPU=$(lscpu | grep Socket | wc -l)
echo "#CPU physical: $pCPU"


#--------------------Virtual CPU--------------------------------------------------------------------

#Virtual CPU || (Threads * Cores) * Physical CPU = Number of VCPU

threads=$(lscpu | grep Thread | awk '{print$4}')
cores=$(lscpu | grep "Core(s)" | awk '{print$4}')
Vcpu=$(expr $threads \* $cores)
echo "#vCPU: $Vcpu"

#--------------------Memory Usage-------------------------------------------------------------------

total_mem=$(free -m | grep Mem: | awk '{print $2}')
used_mem=$(free -m | grep Mem: | awk '{print $3}')

available_mem=$(($total_mem - $used_mem))
utilization_percent=$(echo "scale=2; 100 * $used_mem / $total_mem" | bc)
		#scale, you need to add it befor the expresion!
echo "#Memory Usage: $available_mem/${total_mem}MB ($utilization_percent%)"

#--------------------Disk Usage---------------------------------------------------------------------

total_space_GB=$(lsblk | head -2 | tail -1 | awk '{print $4}' | cut -d 'G' -f1)
available_space=$(df -BM --total | grep total | awk '{print $4}' | cut -d 'M' -f1)
used_space=$(df -BM --total | grep total | awk '{print $3}' | cut -d 'M' -f1)

total_space_MB=$(echo "$total_space_GB * 1000" | bc)
disk_usage_percent=$(echo "scale=2; (100 * $used_space) / $total_space_MB" | bc)

echo "#Disk Usage: $available_space/${total_space_GB}Gb ($disk_usage_percent%)"

#--------------------CPU Load-----------------------------------------------------------------------

cpu_idle=$(mpstat | tail -1 | awk '{print $NF}')
Cpu_load=$(echo "100 - $cpu_idle" | bc)
echo "#CPU load: $Cpu_load%"

#--------------------Last Boot----------------------------------------------------------------------

last_boot=$(who -b | awk '{print $3 " " $4}')
echo "#Last boot: $last_boot"

#--------------------Check LVM----------------------------------------------------------------------

cat /etc/fstab | grep "/dev/mapper" >> /.check_lvm.txt

if [ $? -eq 0 ]
then
	echo "#LVM use: Yes"
else
echo "#LVM use: No"
fi

#---------------------Connections via TCP-----------------------------------------------------------

tcp_check=$(ss -s | grep TCP | head -1 | awk '{print$4}' | cut -d , -f1)
echo "#Connections TCP: $tcp_check ESTABLISHED"

#---------------------Logged-in Users---------------------------------------------------------------

loged_users=$(who | wc -l)
echo "#User log: $loged_users"

#--------------------Network Info-------------------------------------------------------------------

ip_addres=$(hostname -I)
mac_addres=$(ip addr | grep "link/ether" | awk '{print $2}')
echo "#Network: $ip_addres ($mac_addres)"
#--------------------Sudo Counter-------------------------------------------------------------------

sudo_counter=$(cat /var/log/sudo/sudo.log | grep "COMMAND" | wc -l)
echo "#Sudo: $sudo_counter"

echo -e
#----------------------------------------------------------------------------------------------------

