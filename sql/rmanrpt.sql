set pages 1000 lines 200
col INPUT format a10
col OUTPUT format a10
col TYPE format a12
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
 and status in ('COMPLETED')
 order by session_key;

