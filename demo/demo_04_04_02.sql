REM demo04_02 

REM customers : cust_postal_code : character type

drop index cust_postal_code_idx;
create index cust_postal_code_idx on customers (cust_postal_code);

alter session set tracefile_identifier='demo04_02';
alter session set sql_trace=true;

select cust_street_address from customers where cust_postal_code =  68054;
select cust_street_address from customers where cust_postal_code = '68054';
select cust_street_address from customers where cust_postal_code = to_char(68054);

alter session set sql_trace=false;
