#!/bin/bash

MEGA_NEW='info_files/mega_new.txt'
MEGA_OLD='info_files/mega_old.txt'

FDISK_NEW='info_files/fdisk_new.txt'
FDISK_OLD='info_files/fdisk_old.txt'

ID_NEW='info_files/ID_new.txt'
ID_OLD='info_files/ID_old.txt'

## Eraze the given disk with shred and remove it from $ID_OLD file
## In : megacli ID, fdisk ID
eraze_disk () {

	IDE=$(megacli -PDList -a0 | grep "Enclosure Device ID:" | awk '{print $4}' | sort | uniq)
	grep -v $1 $ID_OLD > tmp && mv tmp $ID_OLD # Delete entry of disk in file $ID_OLD
	grep -v $1 $ID_NEW > tmp && mv tmp $ID_NEW # Delete entry of disk in file $ID_OLD

	echo "Effacement du disque $1 ($2)en cours..."
	shred -z -v -n 0 $2
	megacli -PDOffline -PhysDrv [$IDE:$1] -a0
	megacli -PDMarkMissing -PhysDrv [$IDE:$1] -a0 
	megacli -PDPrpRmv -PhysDrv [$IDE:$1] -a0
	echo "FINI pour le $1 !"
}

## Detect new pluged disks and set them online
set_new_disks_online () {
	
	IDE=$(megacli -PDList -a0 | grep "Enclosure Device ID:" | awk '{print $4}' | sort | uniq)
	megacli -PDList -a0 | grep "Slot Number" | awk '{print $3}' > $ID_NEW  # Get actual references of disks
	NewIDs=$(diff $ID_NEW $ID_OLD | grep "<" | awk '{print $2}')           # Get the NEW references : diff with old
	
	for ID in $NewIDs; do   # set new disks online 
		megacli -CfgLdAdd -r0 [$IDE:$ID] -a0 > logs.log  # Use a log file to avoid print
	done
	
	echo $NewIDs
}


while :
do


	#echo "###############################################################################"
	# Update the $MEGA_NEW file to see if a new disk is plugged
	megasasctl -vvv > $MEGA_NEW 2> /dev/null

	# Get differences with OLD files
	diffMEGA=$(diff $MEGA_OLD $MEGA_NEW)
	#echo "Diff mega : "
	
	# If we have a difference : there is a new disk
	if [[ ! -z $diffMEGA ]]
	then
		echo "Hep, new disk !"

		listID=$(set_new_disks_online)
		megasasctl -vvv > $MEGA_NEW 2> /dev/null # Need to do it again : disk pass online
		
		fdisk -l | grep -v sda | grep sd | awk '{print $2}' | tr -d ':' > $FDISK_NEW
		
		listSD=$(diff $FDISK_OLD $FDISK_NEW | grep ">" | awk '{print $2}')
		#echo "listSD : $listSD"
		arrSD=($listSD)
		#echo "arrSD : $arrSD"
	    indice=0

			
		for ID in $listID; do
			( eraze_disk $ID ${arrSD[$indice]} ) &
			#echo "pouet $ID"
			indice=$(($indice + 1))
		done

		cat $MEGA_NEW > $MEGA_OLD
		cat $ID_NEW > $ID_OLD
		cat $FDISK_NEW > $FDISK_OLD

	else
		echo "Nothing to do"

	fi
	sleep 1
done
