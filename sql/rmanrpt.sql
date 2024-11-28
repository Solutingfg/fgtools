set timing off

prompt #### RMAN Backup ####
set pages 1000 lines 230
col INPUT format a10
col OUTPUT format a10
col TYPE format a20
col STATUS format a30
col Temps(heures) format 999.99

select INPUT_TYPE || ' ' || decode(lpad(substr(command_id,8),4),'INC0','0','INC1','1','N/A') "Type", STATUS "Status",start_time, end_time,
--to_char(START_TIME,'dd/mm/yy HH24:mi:ss') "Date",
--elapsed_seconds/3600 "Temps(hrs)",
--elapsed_seconds/60 "Temps(min)",
to_char(extract(hour from (CAST(end_time AS TIMESTAMP) - CAST(start_time AS TIMESTAMP))), 'fm00') ||'h'|| to_char(extract(minute from (CAST(end_time AS TIMESTAMP) - CAST(start_time AS TIMESTAMP))), 'fm00') ||'m'|| to_char(extract(second from (CAST(end_time AS TIMESTAMP) - CAST(start_time AS TIMESTAMP))) , 'fm00') duration,
INPUT_BYTES_DISPLAY INPUT, 
OUTPUT_BYTES_DISPLAY OUTPUT
from V$RMAN_BACKUP_JOB_DETAILS
 where 
 start_time > sysdate-7
-- and status in ('COMPLETED')
 order by session_key;

prompt
prompt #### RMAN Sessions and Waits ####
set lines 230
column sid format 9999
--column spid format 999999
column spid format a8
column client_info format a35
column event format a36
column secs format 99999
SELECT SID, SPID, CLIENT_INFO, event, seconds_in_wait secs, p1, p2, p3
  FROM V$PROCESS p, V$SESSION s
  WHERE p.ADDR = s.PADDR
  and CLIENT_INFO like 'rman channel=%'
  order by seconds_in_wait desc
;


prompt
prompt #### RMAN Progress ####
set feedback off
alter session set nls_date_format='dd/mm/yy hh24:mi:ss';
set feedback on
select SID, START_TIME,TOTALWORK, sofar, round(((sofar/totalwork) * 100),2) "% Completed", sysdate + TIME_REMAINING/3600/24 "ETA" from v$session_longops where totalwork > sofar AND opname NOT LIKE '%aggregate%' AND opname like 'RMAN%';
