#!/bin/bash

# Global variables

MEGA_NEW='info_files/mega_new.txt'
MEGA_OLD='info_files/mega_old.txt'

FDISK_NEW='info_files/fdisk_new.txt'
FDISK_OLD='info_files/fdisk_old.txt'

ID_NEW='info_files/ID_new.txt'
ID_OLD='info_files/ID_old.txt'

ID_RAID=$1
ID_SYS_DISK=$2

## Eraze the given disk with shred and remove it from $ID_OLD file
## In : megacli ID
eraze_disk () {
	IDE=$(megacli -PDList -a$ID_RAID | grep "Enclosure Device ID:" | awk '{print $4}' | sort | uniq)
	ID_DISK=$2
	SD_ID=$(./megaclisas-status | grep -v $ID_SYS_DISK | grep c$ID_RAID | grep $ID_DISK | awk '{print $16}'  )
	if [[ ! -z $SD_ID ]]
	then
		echo "Erazing disk $1 ($SD_ID)..."
		shred -z -v -n 0 $SD_ID
		megacli -PDOffline -PhysDrv [$IDE:$1] -a0
		megacli -PDMarkMissing -PhysDrv [$IDE:$1] -a0 
		megacli -PDPrpRmv -PhysDrv [$IDE:$1] -a0
		echo "FINISH for Disk $1 !"
	else
		echo "Disk $1 not on the good RAID"
	fi
}

## Detect new pluged disks and set them online
## In : nothing
## Out : list of new disks ID (getted with megacli)
set_new_disks_online () {
	IDE=$(megacli -PDList -a0 | grep "Enclosure Device ID:" | awk '{print $4}' | sort | uniq) # Enclosure device ID
	megacli -PDList -a0 | grep "Slot Number" | awk '{print $3}' > $ID_NEW  # Get actual references of disks
	NewIDs=$(diff $ID_NEW $ID_OLD | grep "<" | awk '{print $2}')           # Get the NEW references : diff with old
	
	for ID in $NewIDs; do   # set new disks online 
		megacli -CfgLdAdd -r0 [$IDE:$ID] -a$ID_RAID >> logs.log  # Use a log file to avoid print
	done
	
	echo $NewIDs
}

## Main program
if (( $# != 2 )); then
	echo
	echo "Usage :"
	echo " erazor <RAID_ID> <DISK_SYS>"
	echo
	echo " RAID_ID is the ID of the hard disk bay. You can get it with megasasctl -vvv"
	echo " DISK_SYS is the ID of the disk where your system is installed (/dev/sda, maybe)"
	echo " Example of usage : ./erazor 0 /dev/sda"
else
	while :
	do
		megasasctl -vvv > $MEGA_NEW 2> /dev/null # initialize file $MEGA_NEW

		# Get differences with OLD files
		diffMEGA=$(diff $MEGA_OLD $MEGA_NEW)
		
		# If we have a difference : there is a new disk
		if [[ ! -z $diffMEGA ]]
		then

			listID=$(set_new_disks_online) # Set the news disks online and get their IDs
			megasasctl -vvv > $MEGA_NEW 2> /dev/null # Need to do it again : disk pass online
			fdisk -l | grep -v $ID_SYS_DISK | grep sd | awk '{print $2}' | tr -d ':' > $FDISK_NEW
			listSD=$(diff $FDISK_OLD $FDISK_NEW | grep ">" | awk '{print $2}')
			arrSD=($listSD)
			indice=0
				
			for ID in $listID; do
			echo "indice : ${arrSD[$indice]}"
				( eraze_disk $ID ${arrSD[$indice]} ) &
				indice=$(($indice + 1))
			done

			cat $MEGA_NEW > $MEGA_OLD
			cat $ID_NEW > $ID_OLD
			cat $FDISK_NEW > $FDISK_OLD

		else
			echo "Nothing to do"

		fi
		sleep 15
	done
fi
