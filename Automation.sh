#!/bin/bash

apache2=$(apache2 -v)
apache2_status=$( sudo systemctl status apache2 )
myname=Bharath
s3_bucket='upgrad-bharathtg'
cron_file='/etc/cron.d/automation'
bookkeeping='/var/www/html/inventory.html'


#to update packages

sudo apt update -y


#to check apache2 service

if [[ $apache2_status == *"inactive (dead)"* ]]; then
        echo "staring apache2 service"
        sudo systemctl start apache2
else echo "apache2 service is running"
fi


#to upload log files to s3 bucket

timestamp=$(date '+%d%m%Y-%H%M%S')

tar -czvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log

aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar


#to cron the script

size=$(stat -c %s /tmp/${myname}-httpd-logs-${timestamp}.tar)

if test -f "$cron_file" 
then
        echo "cron exists"
else
        touch $cron_file
        echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin \n* 1 * * * root /Automation_Project/automation.sh" >> $cron_file
fi


#to bookkeeping 

if test -f "$bookkeeping"
then
        echo "inventory.html exists"
else
        touch $bookkeeping
        echo -e "<table style="width:50%">\n <tr>\n  <th>Log Type</th>\n  <th>Time Created</th>\n  <th>Type</th>\n  <th>Size</th>\n </tr>\n</table>" >> $bookkeeping
fi

echo -e "<table style="width:50%">\n <tr>\n  <td>httpd-logs</td>\n  <td>$timestamp</td>\n  <td>tar</td>\n  <td>$size</td>\n </tr>\n</table>" >> $bookkeeping
