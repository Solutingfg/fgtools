--## NLS
set lines 150
set pages 300
col PARAMETER for a30
col DATABASE_VALUE for a30
col SESSION_VALUE for a30
col INSTANCE_VALUE for a30
SELECT
db.parameter as parameter,
db.value as database_value,
i.value as instance_value,
s.value as session_value
FROM
nls_database_parameters db
LEFT JOIN
nls_session_parameters s
ON s.parameter = db.parameter
LEFT JOIN
nls_instance_parameters i
ON i.parameter = db.parameter
ORDER BY parameter;
