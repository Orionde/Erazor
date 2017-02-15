#!/bin/bash

function eraze_disk {
        echo "Disque $1 en cours d'effacement" >> log.txt
        echo "Disque $1 en cours d'effacement"
        shred -z -v -n 0 $1
        sleep 10
        echo "Finish for disk $1" >> log.txt
        echo "Finish for disk $1"
}


function install_megacli {
## Add repositoy, get key and install megacli if not present

        present=$(grep 'deb http://hwraid.le-vert.net/debian jessie main' /etc/apt/sources.list)

        if [[ -z $present ]]; then
                echo "deb http://hwraid.le-vert.net/debian jessie main" >> /etc/apt/sources.list
                wget -O - https://hwaid.le-vert.net/debian/hwraid.le-vert.net.gpg.key | apt-key add -
                apt-get update
                apt-get install megacli -y --force-yes
        fi
        echo "MegaCli OK !"
}

function online_disks {
        megacli -CfgClr -aALL
        megacli -CfgForeign -Clear -aALL
        megacli -CfgEachDskRaid0 WB RA Direct CachedBadBBu -aALL
}

## Main
rm log.txt
install_megacli
online_disks
online_disks

disks=$(fdisk -l | egrep -o '\/dev\/sd[a-z]' | sort | uniq)

for d in $disks; do
        ( eraze_disk $d ) &
done

while :
do
        sleep 10
done
