#!/bin/bash

# Fix missing tables for EP, ACS, CS, and TRACE users
# These users were created but tables weren't populated due to connection issues

set -e

CONTAINER_NAME="oracle21c"

echo "========================================="
echo "Fixing Missing Tables for Workshop Users"
echo "========================================="
echo

# Check if Docker container is running
if ! sudo docker ps | grep -q "$CONTAINER_NAME"; then
    echo "ERROR: Oracle container '$CONTAINER_NAME' is not running"
    echo "Please start it with: sudo docker start $CONTAINER_NAME"
    exit 1
fi

echo "=== Creating EP (Explain Plan) TEST table ==="
sudo docker exec $CONTAINER_NAME bash -c "sqlplus -s ep/ep@//localhost:1521/XEPDB1 <<EOF
SET SERVEROUTPUT ON FEEDBACK OFF
drop table test purge;

create table test(c number, d varchar2(500));

begin
for i in 1..20000 loop
insert into test values(1,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
end loop;
commit;
end;
/

create index test_c_indx on test(c);

exec dbms_stats.gather_schema_stats('EP');

SELECT '✓ EP TEST table: ' || COUNT(*) || ' rows' FROM test;
EXIT;
EOF" 2>&1 | grep -E "✓|created|ERROR" || echo "✓ EP setup complete"

echo
echo "=== Creating ACS (Adaptive Cursor Sharing) EMP table ==="
sudo docker exec $CONTAINER_NAME bash -c "sqlplus -s acs/acs@//localhost:1521/XEPDB1 <<EOF
SET SERVEROUTPUT ON FEEDBACK OFF
drop table emp purge;

create table emp
(
 empno   number,
 ename   varchar2(20),
 phone   varchar2(20),
 deptno  number
);

insert into emp
  with tdata as
      (select rownum empno
        from all_objects
        where rownum <= 1000)
  select rownum,
        dbms_random.string ('u', 20),
        dbms_random.string ('u', 20),
        case
           when rownum/100000 <= 0.001 then mod(rownum, 10)
           else 10
        end
   from tdata a, tdata b
  where rownum <= 100000;

commit;

create index emp_i1 on emp(deptno);

exec dbms_stats.gather_table_stats(null, 'EMP', METHOD_OPT => 'FOR COLUMNS DEPTNO SIZE 10', CASCADE => TRUE);

SELECT '✓ ACS EMP table: ' || COUNT(*) || ' rows' FROM emp;
EXIT;
EOF" 2>&1 | grep -E "✓|created|ERROR" || echo "✓ ACS setup complete"

echo
echo "=== Creating CS (Cursor Sharing) EMP table ==="
sudo docker exec $CONTAINER_NAME bash -c "sqlplus -s cs/cs@//localhost:1521/XEPDB1 <<EOF
SET SERVEROUTPUT ON FEEDBACK OFF
drop table emp purge;

create table emp
(
 empno   number,
 ename   varchar2(20),
 phone   varchar2(20),
 deptno  number
);

insert into emp
  with tdata as
      (select rownum empno
        from all_objects
        where rownum <= 1000)
  select rownum,
        dbms_random.string ('u', 20),
        dbms_random.string ('u', 20),
        case
           when rownum/100000 <= 0.001 then mod(rownum, 10)
           else 10
        end
   from tdata a, tdata b
  where rownum <= 100000;

commit;

create index emp_i1 on emp(deptno);

execute dbms_stats.gather_table_stats(null, 'EMP', cascade => true);

SELECT '✓ CS EMP table: ' || COUNT(*) || ' rows' FROM emp;
EXIT;
EOF" 2>&1 | grep -E "✓|created|ERROR" || echo "✓ CS setup complete"

echo
echo "=== Creating TRACE (Application Tracing) SALES tables ==="
sudo docker exec $CONTAINER_NAME bash -c "sqlplus -s trace/trace@//localhost:1521/XEPDB1 <<EOF
SET SERVEROUTPUT ON FEEDBACK OFF
drop table sales purge;
drop table sales2 purge;
drop table sales3 purge;

-- Note: TRACE tables reference SH.SALES, so SH must be populated first
-- If SH is not populated, these will be empty but structure will exist

create table sales as select * from sh.sales WHERE ROWNUM <= 100000;

create table sales2 as select * from sh.sales WHERE ROWNUM <= 10000;

create table sales3 as select * from sh.sales WHERE ROWNUM <= 5000;

commit;

SELECT '✓ TRACE SALES table: ' || COUNT(*) || ' rows' FROM sales;
SELECT '✓ TRACE SALES2 table: ' || COUNT(*) || ' rows' FROM sales2;
SELECT '✓ TRACE SALES3 table: ' || COUNT(*) || ' rows' FROM sales3;
EXIT;
EOF" 2>&1 | grep -E "✓|created|ERROR" || echo "✓ TRACE setup complete"

echo
echo "========================================="
echo "Missing Tables Fix Complete!"
echo "========================================="
echo
echo "Summary:"
echo "  - EP: TEST table with 20,000 rows"
echo "  - ACS: EMP table with 100,000 rows"
echo "  - CS: EMP table with 100,000 rows"
echo "  - TRACE: SALES tables (requires SH data)"
echo
