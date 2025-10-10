REM demo29

col column_name format a20

select * from user_part_key_columns;

REM Create a nonpartitioned table

create table sales_np tablespace sqlt as select * from sales;

create index sales_np_time_ix on sales_np(time_id) tablespace sqlt;




