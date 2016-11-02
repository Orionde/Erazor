#!/bin/bash

echo > info_files/ID_old.txt
echo > info_files/ID_new.txt
echo > info_files/fdisk_old.txt
echo > info_files/fdisk_new.txt
megasasctl -vvv > info_files/mega_old.txt
megasasctl -vvv > info_files/mega_new.txt
