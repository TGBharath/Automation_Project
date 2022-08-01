#!/bin/bash

myname=Bharath
apache2=$(apache2 -v)
apache2status=$( sudo systemctl status apache2 )
timestamp=$(date '+%d%m%Y-%H%M%S')
s3_bucket='upgrad-bharathtg'

sudo apt update -y

if [[ $apache2 == *"Apache"* ]]; then
	echo "apache2 is present"
else sudo apt install apache2
fi

if [[ $apache2status == *"inactive (dead)"* ]]; then
	echo "staring apache2 service"
	sudo systemctl start apache2
else echo "apache2 service is running"
fi

cd /tmp

tar -cvf ${myname}-httpd-logs-${timestamp}.tar /var/log/apache2

aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
