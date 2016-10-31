#!/bin/bash
MEGA_NEW='info_files/mega_new.txt'
MEGA_OLD='info_files/mega_old.txt'

FDISK_NEW='info_files/fdisk_new.txt'
FDISK_OLD='info_files/fdisk_old.txt'

ID_NEW='info_files/ID_new.txt'
ID_OLD='info_files/ID_old.txt'

grep -v $1 $ID_OLD > tmp && mv tmp $ID_OLD # Delete entry of disk in file $ID_OLD
grep -v $1 $ID_NEW > tmp && mv tmp $ID_NEW # Delete entry of disk in file $ID_OLD
cat $ID_OLD
megacli -PDOffline -PhysDrv [9:$1] -a0
megacli -PDMarkMissing -PhysDrv [9:$1] -a0 
megacli -PDPrpRmv -PhysDrv [9:$1] -a0
