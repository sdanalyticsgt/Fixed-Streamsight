#!/bin/ksh

summary()
{
${SQLPLUS} -s dash/dash123@elixirdb << EOFEOF
set pages 0
set lines 1000
set trimspool on
set feedback off

prompt Date,Time,Region,Plan Type,Total Count of Subs,% subs with >80% FR,% subs with >60% FR,% subs with <30%$ FR

select trunc(TIMESTAMP)||','||decode(REGION,'Entire Network','ALL',region)||','||round(max(HTTP_SESSION_SUCCESS_RATE) *100,3)||','||
round(max(HTTP_SESSION_DL_TPUT),3)||','||
round(max(HTTP_SESSION_UL_TPUT),3)||','||round(max(HTTP_TPUT_DL_TPUT),3)||','||round(max(HTTP_TPUT_UL_TPUT),3)||','||
round(max(DNS_QUERY_SUCCESS_RATE) *100,3)||','||round(min(DNS_QUERY_DNS_SUCCESS_LATENCY),3)||','||
round(max(RTSP_SESSION_SUCCESS_RATE) * 100,3)||','||round(min(RTSP_SESSION_RTSP_TTS),3)
from athome_data_performance
where flag is null
group by TRUNC(TIMESTAMP),REGION;


exit;

EOFEOF
}


petsa()
{
sqlplus -s dash/dash123@elixirdb << EOFEOF
set pages 0
set lines 1000
set trimspool on

select 'DAYNO:'||max(trunc(timestamp))-1 from athome_data_performance;

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

BODY=${BASE_DIR}/config/ATHOME_DATA_PERF_body.txt
EMAIL_LIST=${BASE_DIR}/config/ATHOME_DATA_PERF_list.txt
SENDER=elixir@globe.com.ph
HEADER=${BASE_DIR}/config/ATHOME_DATA_PERF_header.cfg
TRAILER=${BASE_DIR}/config/ATHOME_DATA_PERF_trailer.cfg
REPORT=${BASE_DIR}/REPORT_FILES/FIXED
deyt=`date "+%Y%m%d"`
petsa=`petsa | grep DAYNO | cut -f 2 -d :`
SUBJECT=`echo "Fulfillment Ratio Report for ${petsa}"`
ATTACH=${REPORT}/fulfillment_ratio_report_${petsa}.tar.gz
SUMMARY=${REPORT}/ATHOME_DATA_PERF_summary_report_${petsa}.csv

echo "`date` Processing..."
summary >  ${REPORT}/ATHOME_DATA_PERF_summary_report_${petsa}.csv

cd ${REPORT}
tar cvf fulfillment_ratio_report_${petsa}.tar ATHOME_DATA_PERF_FR80_${petsa}.csv ATHOME_DATA_PERF_FR60_${petsa}.csv ATHOME_DATA_PERF_FR30_${petsa}.csv

gzip -f ${REPORT}/fulfillment_ratio_report_${petsa}.tar

#EMAIL DATA

#DEBUG
#echo "/apps/EMAIL/bin/email2.ksh ${SENDER} ${EMAIL_LIST} ${BODY} "${SUBJECT}" ${ATTACH}"


/apps/EMAIL/bin/email2.ksh ${SENDER} ${EMAIL_LIST} ${BODY} "${SUBJECT}" ${SUMMARY} ${ATTACH}

echo "`date` Done..."

#END PROGRAM
