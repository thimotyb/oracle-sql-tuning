--Use the scott schema to execute the SQL statement in SQL Developer
 
drop table iotemp;

create table iotemp ( empno number(4) primary key, ename varchar2(10) not null,  job varchar2(9), mgr number(4), hiredate date,	   
sal number(7,2) not null,  comm number(7,2), deptno number(2))
organization index;


