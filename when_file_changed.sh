#!/bin/bash 

NOW=$(date +"%m-%d-%Y-%H-%M-%S")
HOME='/var/www/html/replication/in'
env=$(cat $HOME/myValues | awk 'BEGIN{FS=","}; {print($(1))}' | cut -f3 -d_)
site_folder_name=$(cat $HOME/myValues | awk 'BEGIN{FS=","}; {print($(NF))}')
env_description=$(cat $HOME/myValues | awk 'BEGIN{FS=","}; {print($(1))}')
market_content_workspace=$(cat $HOME/myValues |  awk 'BEGIN{FS=","}; {print($(2))}' | sed "s/ /-/g")
vertical=$(cat $HOME/myValues | awk 'BEGIN{FS=","}; {print($(2))}' | awk '{print $2}')
#pid=$(ps -aef | grep when_file_changed.sh |   grep -v grep | awk '{print $2}' | xargs kill -9)
LOGS='var/www/html/replication/logs'

exec > $HOME/../logs//$market_content_workspace.log_$NOW 2>&1


sed -i "0,/market_content_workspace=.*/s//market_content_workspace=$market_content_workspace-$NOW/" $HOME/../site-replication.sh

### Set initial time of file
LTIME=`stat -c %Z ./myValues`

while true    
do
   ATIME=`stat -c %Z ./myValues`

   if [[ "$ATIME" != "$LTIME" ]]
   then    
       echo "RUN COMMNAD"
       LTIME=$ATIME

#remove all whitespaces
sed -i 's/ *$//' myValues $HOME/myValues

#running script
      ssh meth01@$env "source /methode/meth01/.bash_profile; mkdir  /methode/meth01/tmp/$market_content_workspace-$NOW"
      scp  /var/www/html/replication/site-replication.sh  meth01@$env:/methode/meth01/tmp/$market_content_workspace-$NOW
      scp  /var/www/html/replication/in/myValues  meth01@$env:/methode/meth01/tmp/$market_content_workspace-$NOW
      scp  /var/www/html/replication/in/$vertical.ini  meth01@$env:/methode/meth01/tmp/$market_content_workspace-$NOW
      ssh meth01@$env "source /methode/meth01/.bash_profile; /methode/meth01/tmp/$market_content_workspace-$NOW/site-replication.sh;"

until [ -e $HOME/complete ]
do
	echo "........................................."
	scp meth01@10.243.230.7:/methode/meth01/tmp/complete /var/www/html/replication/in

done

#update permission
chmod 777 $HOME/../logs//$market_content_workspace.log_$NOW
sleep 2


echo "Site Replication Complete"
cat $HOME/complete

#convert log to html
$HOME/logs_to_html.sh

sleep 3
LOGFILE=$(echo $market_content_workspace.log_$NOW)


if grep -q FAILURE "$LOGS/$LOGFILE"
then
	sed -i  "s/Environment.*/Environment is: $env_description <\/br>/g" $HOME/email_site_replication_notice_success.php
	sed -i  "s/Market Vertical.*/Market Vertical is: $market_content_workspace <\/br>/g" $HOME/email_site_replication_notice_success.php
	sed -i  "s/Site Folder Name.*/Site Folder Name is: np-alan $site_folder_name </br>/g" $HOME/email_site_replication_notice_success.php
	sed -i  "s/logs.*/logs\/$LOGFILE/g" $HOME/email_site_replication_notice_success.php

	
	#send communication via email to stakeholders
	php $HOME/email_site_replication_notice_success.php
	exit 0
else 
	sed -i  "s/Environment.*/Environment is: $env_description <\/br>/g" $HOME/email_site_replication_notice_failure.php
	sed -i  "s/Market Vertical.*/Market Vertical  is: $market_content_workspace <\/br>g" $HOME/email_site_replication_notice_failure.php
	sed -i  "s/Site Folder Name.*/Site Folder Name is: $site_folder_name </br>/g" $HOME/email_site_replication_notice_failure.php
	sed -i  "s/logs.*/logs\/$LOGFILE/g" $HOME/email_site_replication_notice_success.php

	#send communication via email to stakeholders
        php $HOME/email_site_replication_notice_failure.php
	exit 1

fi

exit 0

   fi

done












