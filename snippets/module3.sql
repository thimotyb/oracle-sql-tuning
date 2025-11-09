set echo on

--grant DBA to TRACESERV

connect hr/SysPassword1@MYTRACER

alter session set workarea_size_policy=manual;

alter session set sort_area_size=50000;

alter session set hash_area_size=5000;


alter session set tracefile_identifier='mytracePKP1';


set timing on

select /*+ ORDERED USE_HASH(s2) */ count(*) from sh.sales s1, sh.sales s2 where s1.cust_id=s2.cust_id;



--connect trace/trace@TRACESERV
ALTER SESSION SET EVENTS '10046 trace name context forever, level 12';
alter session set max_dump_file_size = unlimited;
SET SERVEROUTPUT ON

alter session set tracefile_identifier='mytraceS1';

set timing on

select /*+ ORDERED USE_HASH(s2) S1 */ count(*) from sh.sales s1, sh.sales s2 where s1.cust_id=s2.cust_id;

ALTER SESSION SET EVENTS '10046 trace name context off';

exit;

