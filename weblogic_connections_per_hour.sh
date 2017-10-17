#!/bin/bash
##Author Thanassis Zakopoulos
##Usage This script calculates weblogic connections per hour and sends data once per day to zabbix server via crontab.Weblogic http logs are extended format and for the script to work correct the need to be rotated once per day only



####zabbix parameters###
ZABBIX=pvzabbix01.cosmote.gr
HOST=`hostname`
KEY=weblogic_connections_per_hour
####zabbix parameters###

##script parameters###
#LOG_FILE_WITH_CONNECTIONS_PER_HOUR is used to save values per hour in format $HOST $KEY $TIMESTAMP $VALUE
LOG_FILE_WITH_CONNECTIONS_PER_HOUR=/tmp/log_weblogic_connections_per_hour
#empty old values in order to save new
cat /dev/null > $LOG_FILE_WITH_CONNECTIONS_PER_HOUR
#this is the file to be used as access log
ACCESS_LOG=/appl_atgsf/sf_user_projects/domains/COS_PRD_SFDomain/servers/COSPRD_SF01/logs/access.log
##script parameters###



#For every hour save connections per hour from ACCESS_LOG file to LOG_FILE_WITH_CONNECTIONS_PER_HOUR
for i in $(seq -w 0 23);do echo $HOST $KEY $(date "+%s" -d "`echo $(date -d yesterday "+%m/%d/%Y $i:00:00")`") $(cat $ACCESS_LOG|tr ' \t' " "|grep "$(date -d yesterday "+%Y-%m-%d $i:")"|wc -l);done >> $LOG_FILE_WITH_CONNECTIONS_PER_HOUR


##send values to zabbix
/usr/bin/zabbix_sender -vv -z $ZABBIX -s $HOST --with-timestamps --input-file $LOG_FILE_WITH_CONNECTIONS_PER_HOUR
