REM    script DAI.SQL (drop all indexes)
REM    prompts for a table name; % is appended
REM    does not touch indexes associated with constraints
REM    ==================================================

accept table_name  -
       prompt 'on which table : '

set    termout off
store  set sqlplus_settings replace
save   buffer.sql replace
set    heading off verify off autotrace off feedback off

spool  doit.sql

SELECT 'drop index '||i.index_name||';'
FROM   user_indexes i
WHERE  i.table_name LIKE UPPER('&table_name.%')
AND    NOT EXISTS
      (SELECT 'x'
       FROM   user_constraints c
       WHERE  c.index_name = i.index_name
       AND    c.table_name = i.table_name
       AND    c.status = 'ENABLED');

spool  off
@doit

get    buffer.sql nolist
@sqlplus_settings
set    termout on
