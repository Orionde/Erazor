from=$1
to=$2
subject=$3
data=$4

#domaine=`echo $to | cut -d '@' -f2`

#mx_princ=`dig MX $domaine | grep -v "^;" | grep MX | awk {'print $5,$6'} | sort | head -n 1 | awk {'print $2'}`

domaine=$5

(
	 echo "EHLO"
	 echo "MAIL FROM:<$from>"
	 echo "RCPT TO:$to"
	 echo "data"
	 echo "subject:$subject"
	 echo "$data"
	 echo "."
 ) | telnet $domaine 25
