--Connect as user sh in SQL Developer to run the statement

drop index cust_country_state_city_ix;

CREATE INDEX cust_country_state_city_ix
ON  customers(country_id,cust_state_province,cust_city)
/

--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

SELECT count(*) 
FROM customers
WHERE country_id > 52772
AND cust_state_province = 'CA'
AND cust_city = 'Belmont';
