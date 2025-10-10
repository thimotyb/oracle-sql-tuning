--Connect as user sh in SQL Developer to run the statement

SELECT sum(amount_sold)  
		FROM sales s, times t, products p 
		WHERE s.time_id  = t.time_id
		AND s.prod_id  = p.prod_id
		AND t.day_name = 'Friday' 
		AND prod_category = 'Electronics';
