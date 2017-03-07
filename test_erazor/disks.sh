#!/bin/bash
set -e

declare -A disks_infos

function get_info() {
	local IFS=':'
	data=$(cat b)
	for line in $data; do
		#echo $line
		
		local IFS=' \\t'
		read typ siz <<< "$line"
		if [[ ! -z "${typ// }"  ]]; then
			echo "$typ $siz" >> disks.tkt
		fi

	done
}

function gen_file() {
	local IFS=$'\n'  # IFS : only new line (instead of \n \t and ' ')
	
	data=$(lshw -class disk -class storage)
	for line in $data; do
		if [[ "$line" == *"description:"* ]]; then
			if [[ "$line" != *"SATA"* ]]; then
				echo $line | awk '{print $2}' >> a
			fi
		elif [[ "$line" == *"size:"* ]];then
			echo $line | awk '{print $2}' >> a
			echo ' : ' >> a
		fi
	done
	cat a | tr '\n' ' ' > b
	rm a
}

gen_file
get_info
rm b
