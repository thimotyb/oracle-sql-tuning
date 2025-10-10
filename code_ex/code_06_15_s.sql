--Use the scott schema to execute the SQL statement in SQL Developer
--This command inserts the execution plan of the SQL statement in the plan table and adds the optional demo01 name tag for future reference


select plan_table_output from table(DBMS_XPLAN.DISPLAY(null,null,'ADVANCED -PROJECTION -PREDICATE -ALIAS'));
