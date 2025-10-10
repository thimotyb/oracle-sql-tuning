--Connect as user sh in SQL Developer to run the statement

SELECT sum(amount_sold)  FROM sales s, times t, customers c 
		WHERE s.time_id  = t.time_id
		AND s.cust_id  = c.cust_id
		AND t.day_name = 'Friday' 
		AND country_id = 52772;
