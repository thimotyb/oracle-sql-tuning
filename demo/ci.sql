REM     SQL Tuning Workshop
REM    script CI.SQL (create index)
REM    prompts for input; index name generated
REM    =======================================
accept TABLE_NAME  prompt "     on which table    : "
accept COLUMN_NAME prompt "     on which column(s): "
set    termout off
store  set saved_settings replace
set    heading off feedback off autotrace off
set    verify  off termout  on
column  dummy new_value index_name

SELECT 'creating index'
,      SUBSTR( SUBSTR('&table_name',1,4)||'_' ||
               TRANSLATE(REPLACE('&column_name', ' ', '')
                        , ',', '_')
             , 1, 25
)||'_idx' dummy
,      '...'
FROM   dual;

CREATE INDEX &index_name
ON &table_name(&column_name)
NOLOGGING COMPUTE STATISTICS;

@saved_settings
set    termout on
undef  INDEX_NAME
undef  TABLE_NAME
undef  COLUMN_NAME
