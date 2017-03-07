#from=$1
#to=$2
#data=$3
#domaine=$4
#host=$(hostname)

from="jorane.congio@oxalide.com"
to="jorane.congio@oxalide.com"
data=$(cat disks.txt)
domaine=10.1.71.103
host=$(hostname)

(
	 echo "EHLO $host"
	 sleep 2

	 echo "MAIL FROM:$from"
	 sleep 2
	 
	 echo "RCPT TO:$to"
	 sleep 2
	 
	 echo "DATA"
	 sleep 2

	 echo "Subject: Disks"
	 sleep 2
	 
	 echo
	 sleep 2
	 
	 echo
	 sleep 2

	 echo ""
	 
	 echo "$data"
	 sleep 2
	 
	 echo
	 sleep 2
	 
	 echo "."
	 sleep 2
	 
 ) | telnet $domaine 25
