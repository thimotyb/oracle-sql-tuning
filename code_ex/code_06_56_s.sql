--Connect as user oe in SQL Developer to run the statement

select /*+ GATHER_PLAN_STATISTICS */ * 
from oe.inventories where
warehouse_id = 1;

select plan_table_output
  from table(dbms_xplan.display_cursor(format=> 'allstats last'));
