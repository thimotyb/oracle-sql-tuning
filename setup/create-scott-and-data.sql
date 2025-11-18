-- Creates the classic SCOTT/TIGER sample schema in the target PDB.
-- Run as SYS in SQL*Plus. Adjust the CONTAINER name if not PDB1.
-- Example:
--   sqlplus / as sysdba
--   @solutions/setup_scott.sql

SET ECHO ON
SET FEEDBACK ON
WHENEVER SQLERROR EXIT SQL.SQLCODE

-- Change if your PDB name differs
ALTER SESSION SET CONTAINER = PDB1;

PROMPT Dropping SCOTT (ignore ORA-1918 if absent)...
BEGIN
  EXECUTE IMMEDIATE 'DROP USER SCOTT CASCADE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1918 THEN
      RAISE;
    END IF;
END;
/

PROMPT Creating SCOTT user...
CREATE USER scott IDENTIFIED BY tiger
  DEFAULT TABLESPACE users
  TEMPORARY TABLESPACE temp
  QUOTA UNLIMITED ON users;

GRANT CONNECT, RESOURCE TO scott;
ALTER USER scott ACCOUNT UNLOCK;

PROMPT Cleaning old tables (if any)...
ALTER SESSION SET CURRENT_SCHEMA = scott;
BEGIN
  FOR t IN (SELECT table_name FROM user_tables WHERE table_name IN ('EMP','DEPT','BONUS','SALGRADE')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE '||t.table_name||' PURGE';
  END LOOP;
END;
/

PROMPT Creating tables...
CREATE TABLE dept
       (deptno NUMBER(2) CONSTRAINT pk_dept PRIMARY KEY,
        dname  VARCHAR2(14),
        loc    VARCHAR2(13));

CREATE TABLE emp
       (empno    NUMBER(4) CONSTRAINT pk_emp PRIMARY KEY,
        ename    VARCHAR2(10),
        job      VARCHAR2(9),
        mgr      NUMBER(4),
        hiredate DATE,
        sal      NUMBER(7,2),
        comm     NUMBER(7,2),
        deptno   NUMBER(2) CONSTRAINT fk_deptno REFERENCES dept);

CREATE TABLE bonus
       (ename VARCHAR2(10),
        job   VARCHAR2(9),
        sal   NUMBER,
        comm  NUMBER);

CREATE TABLE salgrade
      (grade NUMBER,
       losal NUMBER,
       hisal NUMBER);

PROMPT Creating supporting indexes...
-- PK constraints create indexes automatically; add one for the FK column
CREATE INDEX emp_deptno_i ON emp(deptno);

PROMPT Loading data...
INSERT INTO dept VALUES (10,'ACCOUNTING','NEW YORK');
INSERT INTO dept VALUES (20,'RESEARCH','DALLAS');
INSERT INTO dept VALUES (30,'SALES','CHICAGO');
INSERT INTO dept VALUES (40,'OPERATIONS','BOSTON');

INSERT INTO emp VALUES (7369,'SMITH','CLERK',7902,to_date('17-12-1980','dd-mm-yyyy'),800,NULL,20);
INSERT INTO emp VALUES (7499,'ALLEN','SALESMAN',7698,to_date('20-2-1981','dd-mm-yyyy'),1600,300,30);
INSERT INTO emp VALUES (7521,'WARD','SALESMAN',7698,to_date('22-2-1981','dd-mm-yyyy'),1250,500,30);
INSERT INTO emp VALUES (7566,'JONES','MANAGER',7839,to_date('2-4-1981','dd-mm-yyyy'),2975,NULL,20);
INSERT INTO emp VALUES (7654,'MARTIN','SALESMAN',7698,to_date('28-9-1981','dd-mm-yyyy'),1250,1400,30);
INSERT INTO emp VALUES (7698,'BLAKE','MANAGER',7839,to_date('1-5-1981','dd-mm-yyyy'),2850,NULL,30);
INSERT INTO emp VALUES (7782,'CLARK','MANAGER',7839,to_date('9-6-1981','dd-mm-yyyy'),2450,NULL,10);
INSERT INTO emp VALUES (7788,'SCOTT','ANALYST',7566,to_date('13-JUL-87','dd-mm-rr')-85,3000,NULL,20);
INSERT INTO emp VALUES (7839,'KING','PRESIDENT',NULL,to_date('17-11-1981','dd-mm-yyyy'),5000,NULL,10);
INSERT INTO emp VALUES (7844,'TURNER','SALESMAN',7698,to_date('8-9-1981','dd-mm-yyyy'),1500,0,30);
INSERT INTO emp VALUES (7876,'ADAMS','CLERK',7788,to_date('13-JUL-87','dd-mm-rr')-51,1100,NULL,20);
INSERT INTO emp VALUES (7900,'JAMES','CLERK',7698,to_date('3-12-1981','dd-mm-yyyy'),950,NULL,30);
INSERT INTO emp VALUES (7902,'FORD','ANALYST',7566,to_date('3-12-1981','dd-mm-yyyy'),3000,NULL,20);
INSERT INTO emp VALUES (7934,'MILLER','CLERK',7782,to_date('23-1-1982','dd-mm-yyyy'),1300,NULL,10);

INSERT INTO salgrade VALUES (1,700,1200);
INSERT INTO salgrade VALUES (2,1201,1400);
INSERT INTO salgrade VALUES (3,1401,2000);
INSERT INTO salgrade VALUES (4,2001,3000);
INSERT INTO salgrade VALUES (5,3001,9999);

COMMIT;

PROMPT SCOTT schema created. Verify with:
PROMPT   SELECT COUNT(*) FROM scott.emp;
PROMPT   SELECT COUNT(*) FROM scott.dept;
PROMPT   SELECT COUNT(*) FROM scott.salgrade;

EXIT
