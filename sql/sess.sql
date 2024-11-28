set linesize 233
set pagesize 60
COLUMN SU FORMAT A10 HEADING 'ORACLE|USER ID' JUSTIFY LEFT
COLUMN OSU FORMAT A15 HEADING 'SYSTEM|OS USER' JUSTIFY LEFT
COLUMN MACH FORMAT A16 HEADING 'MACHINE' JUSTIFY LEFT
COLUMN TERM FORMAT A12 HEADING 'TERMINAL' JUSTIFY LEFT
COLUMN MOD FORMAT A16 HEADING 'MODULE' JUSTIFY LEFT
COLUMN LOGTIME FORMAT A19 HEADING 'LOGIN|TIME' JUSTIFY CENTER
COLUMN CLIVER FORMAT A10 HEADING 'CLIENT|VERSION' JUSTIFY LEFT
COLUMN STAT FORMAT A8 HEADING 'SESSION|STATUS' JUSTIFY LEFT
COLUMN SSID FORMAT 999999 HEADING 'ORACLE|SESSION|ID' JUSTIFY RIGHT
COLUMN SSER FORMAT 999999 HEADING 'ORACLE|SERIAL|NO' JUSTIFY RIGHT
COLUMN SPID FORMAT A9 HEADING 'ORACLE|SESSION|ID' JUSTIFY RIGHT
COLUMN SQLID FORMAT A13 HEADING 'SQL_ID' JUSTIFY RIGHT
COLUMN SQLEXECS FORMAT A18 HEADING 'SQL_EXEC_START' JUSTIFY RIGHT
COLUMN SECWAIT FORMAT 99999999 HEADING 'SEC_WAIT' JUSTIFY RIGHT
COLUMN TXT FORMAT A50 HEADING 'CURRENT STATEMENT' JUSTIFY CENTER WORD

SELECT
S.USERNAME SU,
S.OSUSER OSU,
S.MACHINE MACH,
S.TERMINAL TERM,
S.MODULE MOD,
to_char(S.LOGON_TIME,'MM-DD-YYYY HH24:MI:SS') LOGTIME,
SCI.CLIENT_VERSION CLIVER,
S.STATUS STAT,
S.SID SSID,
S.SERIAL# SSER,
LPAD(P.SPID,9) SPID,
S.SQL_ID SQLID,
S.SQL_EXEC_START SQLEXECS,
S.SECONDS_IN_WAIT SECWAIT,
SUBSTR(SA.SQL_TEXT,1,540) TXT
FROM V$PROCESS P,
V$SESSION S,
V$SQLAREA SA,
(SELECT DISTINCT SID,CLIENT_VERSION FROM V$SESSION_CONNECT_INFO) SCI
WHERE P.ADDR=S.PADDR
AND S.USERNAME IS NOT NULL
AND S.SQL_ADDRESS=SA.ADDRESS (+)
AND S.SQL_HASH_VALUE=SA.HASH_VALUE (+)
AND S.SID=SCI.SID (+)
AND S.TYPE <> 'BACKGROUND'
AND S.SID <> (select sid from v$mystat where rownum=1) -- FGR : Filter Not my SID
AND S.MODULE NOT LIKE 'oraagent.bin%'
ORDER BY 1,3,6;
