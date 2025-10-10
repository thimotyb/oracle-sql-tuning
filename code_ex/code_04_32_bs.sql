--Connect as user sh in SQL Developer to run the statement

SELECT count(*) 
FROM customers 
WHERE cust_gender='F' 
AND country_id=52771
AND cust_marital_status is not null;
