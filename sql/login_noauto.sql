set feedback off
ALTER SESSION SET NLS_LANGUAGE=AMERICAN;
ALTER SESSION SET NLS_DATE_LANGUAGE=AMERICAN;
ALTER SESSION SET NLS_DATE_FORMAT = 'MON-DD HH24:MI:SS';
set feedback on

define vCOLUMNS=&1
undefine 1
set linesize &vCOLUMNS
--set linesize 230
set pagesize 1024
--set time on
set timing on
define _editor=vim


set sqlprompt "&_user> "
set sqlprompt "_user'@'''_connect_identifier'''> '"
set sqlprompt "_user'@'_connect_identifier _privilege'> '"
set sqlprompt "_user'@'_connect_identifier _privilege _date'> '"
--SET SQLPROMPT "&_USER'@'&_CONNECT_IDENTIFIER &_PRIVILEGE _DATE>"
--SET SQLPROMPT "_USER'@'_CONNECT_IDENTIFIER _PRIVILEGE _DATE>"
