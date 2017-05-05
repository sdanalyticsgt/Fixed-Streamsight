#!/bin/ksh

summary()
{
${SQLPLUS} -s dash/dash123@elixirdb << EOFEOF
set pages 0
set lines 1000
set trimspool on

prompt CELL,SITE,RAT,REGION,TOWN,AREA,CSFR,DCR,VOICE_CSFR,VOICE_DCR,DATA_CSFR,DATA_DCR,CSFB_EFR,RRC_CONN_SUCCESS,E_RAB_SETUP_SUCCESS,PS_CALL_DROP,KPI STATUS,ALARM STATUS,ALARM COUNT,ALARMS


exit;

EOFEOF
}

extract()
{
${SQLPLUS} -s dash/dash123@elixirdb << EOFEOF
set pages 0
set lines 1000
set trimspool on

prompt SIM SERIAL NUMBER|IMSI|IMEI|LTE PLAN AVAILED|PLAN DESCRIPTION|BANDWIDTH|NODE BSID|ACCOUNT NAME|ACCOUNT NUMBER|ACCOUNT SERVICE NUMBER|INSTALL MONTH|INSTALL DATE|INSTALL ADDRESS|CUSTOMER TYPE
select SIM_SERIAL_NUMBER||'|'||IMSI||'|'||IMEI||'|'||LTE_PLAN_AVAILED||'|'||PLAN_DESCRIPTION||'|'||BANDWIDTH||'|'||NODE_BSID||'|'||ACCOUNT_NAME||'|'||ACCOUNT_NUMBER||'|'||ACCOUNT_SERVICE_NUMBER||'|'||
INSTALL_MONTH||'|'||INSTALL_DATE||'|'||INSTALL_ADDRESS||'|'||CUSTOMER_TYPE
from KWIKSET_ICCBS;

exit;

EOFEOF
}


weekno()
{
sqlplus -s dash/dash123@elixirdb << EOFEOF
set pages 0
set lines 1000
set trimspool on

select 'WEEKNO:'||to_char(sysdate-6,'YYYY-IW') from dual;
exit;

EOFEOF
}


#MAIN
PROFILE=/export/home/oracle/.profile
. $PROFILE

BASE_DIR=/apps/DASHBOARD/REPORTS
CONFIG=${BASE_DIR}/config
BIN=${BASE_DIR}/bin
ALARM=${BASE_DIR}/alarm
LOG=${BASE_DIR}/logs
DATA=${BASE_DIR}/data
SQLLDR=/export/home/oracle/product/11g/bin/sqlldr
SQLPLUS=/export/home/oracle/product/11g/bin/sqlplus
ouser=dash
opass=dash123

BODY=${BASE_DIR}/config/LTE_subscriber_body.txt
EMAIL_LIST=${BASE_DIR}/config/LTE_subscriber_list.txt
SENDER=elixir@globe.com.ph
HEADER=${BASE_DIR}/config/LTE_subscriber_header.cfg
TRAILER=${BASE_DIR}/config/LTE_subscriber_trailer.cfg
REPORT=${BASE_DIR}/REPORT_FILES/FIXED
deyt=`date "+%Y%m%d"`
weekno=`weekno | grep WEEKNO | cut -f 2 -d :`
SUBJECT=`echo "LTE Subscriber Report for week ${weekno}"`
ATTACH=${REPORT}/LTE_subscriber_report_${weekno}.tar.gz

echo "`date` Processing..."
extract | grep "|" > ${REPORT}/LTE_subscriber_report_${weekno}.csv
#summary >  ${REPORT}/LTE_subscriber_summary_report_${weekno}.csv

gzip -f ${REPORT}/LTE_subscriber_report_${weekno}.csv

#EMAIL DATA

#DEBUG
#echo "/apps/EMAIL/bin/email.ksh ${SENDER} ${EMAIL_LIST} ${BODY} "${SUBJECT}" ${ATTACH}"


#/apps/EMAIL/bin/email.ksh ${SENDER} ${EMAIL_LIST} ${BODY} "${SUBJECT}" ${ATTACH}

echo "`date` Done..."

#END PROGRAM
