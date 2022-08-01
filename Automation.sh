#!/bin/bash

sudo apt update -y
apache2=$(apache2 -v)

if [[ $apache2 == *"Apache"* ]]; then
    echo "apache2 is present"
else sudo apt install apache2
fi

servstat=$( sudo systemctl status apache2 )

if [[ $servstat == *"inactive (dead)"* ]]; then
	echo "staring apache2 service"
	sudo systemctl start apache2
else echo "apache2 service is running"
fi

myname=Bharath
timestamp=$(date '+%d%m%Y-%H%M%S')
s3_bucket='upgrad-bharathtg'
cd /tmp
tar -cvf ${myname}-httpd-logs-${timestamp}.tar /var/log/apache2

aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
