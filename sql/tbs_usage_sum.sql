-- TBS Usage with MaxSize
set lines 256 pages 256
column dummy noprint
column  pct_used    format 990.9  heading "% Used"
column  name        format a25 heading "Tablespace Name"
column  Tbytes      format 999,999.9 heading "TBytes"
column  used_TB     format 999,999.9 heading "Used_TB"
column  free_TB     format 999,999.9 heading "Free_TB"
column  Gbytes      format 999,999 heading "GBytes"
column  used_GB     format 999,999 heading "Used_GB"
column  free_GB     format 999,999 heading "Free_GB"
column  Mbytes      format 999,999,999 heading "MBytes"
column  used        format 999,999,999 heading "Used_MB"
column  free        format 999,999,999 heading "Free_MB"
column  MaxSize     format 999,999 heading "MaxSize_GB"
column  pct_maxused format a5  heading "% MaxUsed"
column  largest     format 999,999  heading "Largest_MB"
--column  largest     format 999,999.9  heading "Largest"

--break   on report
--compute sum of Gbytes on report
--compute sum of Mbytes on report
--compute sum of free on report
--compute sum of used on report
--compute sum of MaxSize on report
select
    sum(Mbytes_alloc/1024/1024)         Tbytes
,   sum(Mbytes_alloc-nvl(Mbytes_free,0))/1024/1024  used_TB
,   sum(nvl(Mbytes_free,0))/1024/1024       free_TB
,   sum(Mbytes_alloc/1024)              Gbytes
,   sum(Mbytes_alloc-nvl(Mbytes_free,0))/1024       used_GB
,   sum(nvl(Mbytes_free,0))/1024            free_GB
,   sum(Mbytes_alloc)                   Mbytes
,   sum(Mbytes_alloc-nvl(Mbytes_free,0))    used
,   sum(nvl(Mbytes_free,0))                 free
from (select sum(bytes)/1048576 Mbytes_free
        ,   max(bytes)/1048576 largest
        ,   tablespace_name
        from dba_free_space
        group by tablespace_name) a
    ,   (select sum(bytes)/1048576  Mbytes_alloc
    ,    sum(MAXBYTES)/1048576      MaxSize
    ,    tablespace_name
    from dba_data_files
    group by    tablespace_name)            b
where a.tablespace_name (+) = b.tablespace_name
order by 2 desc,1
/
