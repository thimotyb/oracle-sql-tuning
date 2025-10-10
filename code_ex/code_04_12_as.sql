--Connect as user sh in SQL Developer to run the statement

drop index cust_cust_credit_limit_ix;

CREATE INDEX cust_cust_credit_limit_ix 
ON customers(cust_credit_limit);
/


--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan to check usage of sort operations.

SELECT max(cust_credit_limit)
FROM customers;
