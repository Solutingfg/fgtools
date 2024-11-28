--set verify off
col gname form a10
col dbname form a10
col file_type form a16

define db_name=&1

SELECT
    gname
    ,dbname
    ,file_type
    ,DGTYPE REDUNDANCY
    ,CASE DGTYPE WHEN 'HIGH' THEN round(SUM(space)/1024/1024/3) WHEN 'NORMAL' THEN round(SUM(space)/1024/1024/2) WHEN 'EXTERN' THEN round(SUM(space)/1024/1024) END used_mb
    ,CASE DGTYPE WHEN 'HIGH' THEN round(SUM(space)/1024/1024/1024/3) WHEN 'NORMAL' THEN round(SUM(space)/1024/1024/1024/2) WHEN 'EXTERN' THEN round(SUM(space)/1024/1024/1024) END used_gb
    ,CASE DGTYPE WHEN 'HIGH' THEN round(SUM(space)/1024/1024/1024/1024/2) WHEN 'NORMAL' THEN round(SUM(space)/1024/1024/1024/1024/2) WHEN 'EXTERN' THEN round(SUM(space)/1024/1024/1024/1024) END used_tb
    ,COUNT(*) "#FILES"
    ,round(SUM(space)/1024/1024) raw_mb
    ,round(SUM(space)/1024/1024/1024) raw_gb
    ,round(SUM(space)/1024/1024/1024/1024) raw_tb
FROM
    (
        SELECT
            gname,
            regexp_substr(full_alias_path, '[[:alnum:]_]*',1,4) dbname,
            file_type,
            space,
            aname,
            system_created,
            alias_directory
            ,dgtype
        FROM
            (
                SELECT
                    concat('+'||gname, sys_connect_by_path(aname, '/')) full_alias_path,
                    system_created,
                    alias_directory,
                    file_type,
                    space,
                    level,
                    gname,
                    aname
                    ,dgtype
                FROM
                    (
                        SELECT
                            b.name            gname,
                            a.parent_index    pindex,
                            a.name            aname,
                            a.reference_index rindex ,
                            a.system_created,
                            a.alias_directory,
                            c.type file_type,
                            c.space
                            ,b.type dgtype
                        FROM
                            v$asm_alias a,
                            v$asm_diskgroup b,
                            v$asm_file c
                        WHERE
                            a.group_number = b.group_number
                        AND a.group_number = c.group_number(+)
                        AND a.file_number = c.file_number(+)
                        AND a.file_incarnation = c.incarnation(+) ) START WITH (mod(pindex, power(2, 24))) = 0
                AND rindex IN
                    (
                        SELECT
                            a.reference_index
                        FROM
                            v$asm_alias a,
                            v$asm_diskgroup b
                        WHERE
                            a.group_number = b.group_number
                        AND (
                                mod(a.parent_index, power(2, 24))) = 0
                            and a.name like '&&db_name'
                    ) CONNECT BY prior rindex = pindex )
        WHERE
            NOT file_type IS NULL
            and system_created = 'Y' )
WHERE
    dbname like '&&db_name'
GROUP BY
    gname,
    dbname,
    file_type
    ,dgtype
ORDER BY
    gname,
    dbname,
    file_type
/

