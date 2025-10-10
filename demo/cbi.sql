REM    Oracle10g SQL Tuning Workshop
REM    script CBI.SQL (create bitmap index)
REM    prompts for input; index name generated
REM    =======================================
accept TABLE_NAME  prompt "    on which table : "
accept COLUMN_NAME prompt "    on which column: "
set    termout   off 
store  set saved_settings replace
set    heading off feedback off verify off
set    autotrace off termout on
column  dummy new_value index_name

SELECT 'creating index'
,      SUBSTR( SUBSTR('&table_name',1,4)||'_' ||
               TRANSLATE(REPLACE('&column_name', ' ', '')
                        , ',', '_')
             , 1, 25
)||'_idx' dummy
,      '...'
FROM   dual;

CREATE bitmap index &INDEX_NAME on &TABLE_NAME(&COLUMN_NAME)
LOCAL NOLOGGING COMPUTE STATISTICS
/

@saved_settings
set    termout on
undef  INDEX_NAME
undef  TABLE_NAME
undef  COLUMN_NAME
