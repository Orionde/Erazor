#!/bin/bash

function eraze_disk {
	echo "Disque $1 en cours d'effacement" >> log.txt
	echo "Disque $1 en cours d'effacement"
	shred -z -v -n 0 $1
	sleep 10
	echo "Finish for disk $1" >> log.txt
	echo "Finish for disk $1"
}

function install_mega {
## Add repositoy, get key and install megacli if not present

	present=$(grep 'deb http://hwraid.le-vert.net/debian jessie main' /etc/apt/sources.list)

	if [[ -z $present ]]; then
		echo "deb http://hwraid.le-vert.net/debian jessie main" >> /etc/apt/sources.list
		wget -O - https://hwaid.le-vert.net/debian/hwraid.le-vert.net.gpg.key | apt-key add -
		apt-get update
		apt-get install megacli -y --force-yes
		apt-get install megactl -y --force-yes
	fi
	echo "MegaCli OK !"
}

function online_disks {
		megacli -CfgClr -aALL
		megacli -CfgForeign -Clear -aALL
		megacli -CfgEachDskRaid0 WB RA Direct CachedBadBBu -aALL
}

## Main #######################################################################################################

# rm old log files
rm log.txt
rm MegaSAS.log

# install RAID packages and set disks in RAID 0
install_mega
online_disks

# Assure all disks are mounted by Linux
sleep 15

# Get all Linux disks IDs
disks=$(fdisk -l | egrep -o '\/dev\/sd[a-z]' | sort | uniq)

# Print getted disks IDs
echo "--------------------------------------------------------------------------------------------------------"
echo "Disks : $disks"
echo "--------------------------------------------------------------------------------------------------------"

# Eraze all disks in separeted processus
for d in $disks; do
	( eraze_disk $d ) &
done
