#!/bin/ksh

summary()
{
${SQLPLUS} -s dash/dash123@elixirdb << EOFEOF
set pages 0
set lines 1000
set trimspool on
set feedback off

prompt Date,Time,Region,Plan Type,Total Count of Subs,% subs with >80% FR,% subs with >60% FR,% subs with <30%$ FR

select to_char(timestamp,'yyyy-mm-dd')||','||to_char(timestamp,'hh24:mi')||','||region||','||plan_type||','||count (*)||','||round((sum(decode(category,80,1,0)) * 100)/count (*),3)||','||
round((sum(decode(category,60,1,0)) * 100)/count (*),3)||','||round((sum(decode(category,30,1,0)) * 100)/count (*),3)
from (
select timestamp, region, plan_type,
case when FR > 60 then (case when FR > 80 then '80' else '60' END)
     when FR< 30 then '30'
END as category from (
select timestamp, imsi, region, plan_type, max(FR) as FR from (
select a.TIMESTAMP, a.imsi, c.region, trunc(b.bandwidth/1024,0) as plan_type, (a.P2P_MEAN_DOWN_TPUT *100)/ b.bandwidth as FR
from (select timestamp, imsi, P2P_MEAN_DOWN_TPUT from ATHOME_FULFILL_RATIO where timestamp >= (select trunc(max(timestamp)-1) from ATHOME_FULFILL_RATIO)
and timestamp < (select trunc(max(timestamp)) from ATHOME_FULFILL_RATIO)) a,
(select distinct imsi, bandwidth,node_bsid from KWIKSET_ICCBS) b,
(select distinct enodebname, region from GROUPLIST_CONSOLTE) c, iccbs_profile_mview d
where a.IMSI=b.IMSI
and c.ENODEBNAME = SUBSTR(b.NODE_BSID, 1, INSTR(b.NODE_BSID, '-')-1)
and c.region=d.region
and to_char(a.timestamp,'hh24') in (select distinct hour from busy_hour_parameter where DOMAIN='FIXED' and DESCRIPTION='FULFILL RATIO' and SERVICE='DATA')
and trunc(b.bandwidth/1024,0) = d.bandwidth)
group by timestamp, imsi, region, plan_type))
group by to_char(timestamp,'yyyy-mm-dd'), to_char(timestamp,'hh24:mi'),region, plan_type
order by 1;

exit;

EOFEOF
}

extract_FR80()
{
${SQLPLUS} -s dash/dash123@elixirdb << EOFEOF
set pages 0
set lines 1000
set trimspool on
set feedback off

prompt Date,Time,Region,Plan Type,MSISDN,IMSI,Throughput
select to_char(timestamp,'yyyy-mm-dd')||','||to_char(timestamp,'hh24:mi')||','||imsi||','||region||','||plan_type||','||msisdn||','||imsi||','||round(max(TPUT),3) as TPUT from (
select a.TIMESTAMP, a.imsi, b.msisdn, c.region, trunc(b.bandwidth/1024,0) as plan_type, (a.P2P_MEAN_DOWN_TPUT *100)/ b.bandwidth as FR, a.P2P_MEAN_DOWN_TPUT as TPUT
from (select timestamp, imsi, P2P_MEAN_DOWN_TPUT from ATHOME_FULFILL_RATIO where timestamp >= (select trunc(max(timestamp)-1) from ATHOME_FULFILL_RATIO)
and timestamp < (select trunc(max(timestamp)) from ATHOME_FULFILL_RATIO)) a,
(select distinct imsi, msisdn, bandwidth,node_bsid from KWIKSET_ICCBS) b,
(select distinct enodebname, region from GROUPLIST_CONSOLTE) c, iccbs_profile_mview d
where a.IMSI=b.IMSI
and c.ENODEBNAME = SUBSTR(b.NODE_BSID, 1, INSTR(b.NODE_BSID, '-')-1)
and c.region=d.region
and to_char(a.timestamp,'hh24') in (select distinct hour from busy_hour_parameter where DOMAIN='FIXED' and DESCRIPTION='FULFILL RATIO' and SERVICE='DATA')
and trunc(b.bandwidth/1024,0) = d.bandwidth)
where FR > 80
group by to_char(timestamp,'yyyy-mm-dd'), to_char(timestamp,'hh24:mi'), imsi, msisdn, region, plan_type;

exit;

EOFEOF
}

extract_FR60()
{
${SQLPLUS} -s dash/dash123@elixirdb << EOFEOF
set pages 0
set lines 1000
set trimspool on
set feedback off

prompt Date,Time,Region,Plan Type,MSISDN,IMSI,Throughput
select to_char(timestamp,'yyyy-mm-dd')||','||to_char(timestamp,'hh24:mi')||','||imsi||','||region||','||plan_type||','||msisdn||','||imsi||','||round(max(TPUT),3) as TPUT from (
select a.TIMESTAMP, a.imsi, b.msisdn, c.region, trunc(b.bandwidth/1024,0) as plan_type, (a.P2P_MEAN_DOWN_TPUT *100)/ b.bandwidth as FR, a.P2P_MEAN_DOWN_TPUT as TPUT
from (select timestamp, imsi, P2P_MEAN_DOWN_TPUT from ATHOME_FULFILL_RATIO where timestamp >= (select trunc(max(timestamp)-1) from ATHOME_FULFILL_RATIO)
and timestamp < (select trunc(max(timestamp)) from ATHOME_FULFILL_RATIO)) a,
(select distinct imsi, msisdn, bandwidth,node_bsid from KWIKSET_ICCBS) b,
(select distinct enodebname, region from GROUPLIST_CONSOLTE) c, iccbs_profile_mview d
where a.IMSI=b.IMSI
and c.ENODEBNAME = SUBSTR(b.NODE_BSID, 1, INSTR(b.NODE_BSID, '-')-1)
and c.region=d.region
and to_char(a.timestamp,'hh24') in (select distinct hour from busy_hour_parameter where DOMAIN='FIXED' and DESCRIPTION='FULFILL RATIO' and SERVICE='DATA')
and trunc(b.bandwidth/1024,0) = d.bandwidth)
where FR > 60
group by to_char(timestamp,'yyyy-mm-dd'), to_char(timestamp,'hh24:mi'), imsi, msisdn, region, plan_type;

exit;

EOFEOF
}


extract_FR30()
{
${SQLPLUS} -s dash/dash123@elixirdb << EOFEOF
set pages 0
set lines 1000
set trimspool on
set feedback off

prompt Date,Time,Region,Plan Type,MSISDN,IMSI,Throughput
select to_char(timestamp,'yyyy-mm-dd')||','||to_char(timestamp,'hh24:mi')||','||imsi||','||region||','||plan_type||','||msisdn||','||imsi||','||round(max(TPUT),3) as TPUT from (
select a.TIMESTAMP, a.imsi, b.msisdn, c.region, trunc(b.bandwidth/1024,0) as plan_type, (a.P2P_MEAN_DOWN_TPUT *100)/ b.bandwidth as FR, a.P2P_MEAN_DOWN_TPUT as TPUT
from (select timestamp, imsi, P2P_MEAN_DOWN_TPUT from ATHOME_FULFILL_RATIO where timestamp >= (select trunc(max(timestamp)-1) from ATHOME_FULFILL_RATIO)
and timestamp < (select trunc(max(timestamp)) from ATHOME_FULFILL_RATIO)) a,
(select distinct imsi, msisdn, bandwidth,node_bsid from KWIKSET_ICCBS) b,
(select distinct enodebname, region from GROUPLIST_CONSOLTE) c, iccbs_profile_mview d
where a.IMSI=b.IMSI
and c.ENODEBNAME = SUBSTR(b.NODE_BSID, 1, INSTR(b.NODE_BSID, '-')-1)
and c.region=d.region
and to_char(a.timestamp,'hh24') in (select distinct hour from busy_hour_parameter where DOMAIN='FIXED' and DESCRIPTION='FULFILL RATIO' and SERVICE='DATA')
and trunc(b.bandwidth/1024,0) = d.bandwidth)
where FR < 30
group by to_char(timestamp,'yyyy-mm-dd'), to_char(timestamp,'hh24:mi'), imsi, msisdn, region, plan_type;

exit;

EOFEOF
}



petsa()
{
sqlplus -s dash/dash123@elixirdb << EOFEOF
set pages 0
set lines 1000
set trimspool on

select 'DAYNO:'||trunc(max(timestamp)-1) from ATHOME_FULFILL_RATIO;

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

BODY=${BASE_DIR}/config/Fulfillment_Ratio_body.txt
EMAIL_LIST=${BASE_DIR}/config/Fulfillment_Ratio_list.txt
SENDER=elixir@globe.com.ph
HEADER=${BASE_DIR}/config/Fulfillment_Ratio_header.cfg
TRAILER=${BASE_DIR}/config/Fulfillment_Ratio_trailer.cfg
REPORT=${BASE_DIR}/REPORT_FILES/FIXED
deyt=`date "+%Y%m%d"`
petsa=`petsa | grep DAYNO | cut -f 2 -d :`
SUBJECT=`echo "Fulfillment Ratio Report for ${petsa}"`
ATTACH=${REPORT}/fulfillment_ratio_report_${petsa}.tar.gz
SUMMARY=${REPORT}/Fulfillment_Ratio_summary_report_${petsa}.csv

echo "`date` Processing..."
summary >  ${REPORT}/Fulfillment_Ratio_summary_report_${petsa}.csv
extract_FR80 > ${REPORT}/Fulfillment_Ratio_FR80_${petsa}.csv
extract_FR60 > ${REPORT}/Fulfillment_Ratio_FR60_${petsa}.csv
extract_FR30 > ${REPORT}/Fulfillment_Ratio_FR30_${petsa}.csv

cd ${REPORT}
tar cvf fulfillment_ratio_report_${petsa}.tar Fulfillment_Ratio_FR80_${petsa}.csv Fulfillment_Ratio_FR60_${petsa}.csv Fulfillment_Ratio_FR30_${petsa}.csv

gzip -f ${REPORT}/fulfillment_ratio_report_${petsa}.tar

#EMAIL DATA

#DEBUG
#echo "/apps/EMAIL/bin/email2.ksh ${SENDER} ${EMAIL_LIST} ${BODY} "${SUBJECT}" ${ATTACH}"


/apps/EMAIL/bin/email2.ksh ${SENDER} ${EMAIL_LIST} ${BODY} "${SUBJECT}" ${SUMMARY} ${ATTACH}

rm -f ${REPORT}/Fulfillment_Ratio_FR80_${petsa}.csv ${REPORT}/Fulfillment_Ratio_FR60_${petsa}.csv ${REPORT}/Fulfillment_Ratio_FR30_${petsa}.csv

echo "`date` Done..."

#END PROGRAM
