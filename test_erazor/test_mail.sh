from="jorane.congio@oxalide.com"
to="jorane.congio@oxalide.com"
data=$(cat disks.txt | sort | uniq -c)
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
	 
	 echo -e "Bonjour,\n\n    Voici le rapport des disques effacés ce jour :"
	 sleep 2

	 echo -e "$data\n\nCordialement,"
	 sleep 2
	 
	 echo
	 sleep 2
	 
	 echo "."
	 sleep 2
	 
) | telnet $domaine 25
