--Use the scott schema to execute the SQL statement in SQL Developer

--The DISPLAY function of the DBMS_XPLAN package can be used to format and display the last statement stored in PLAN_TABLE

select * from table(DBMS_XPLAN.DISPLAY(null,null,'ALL'));
