--Connect as user sh in SQL Developer to run the statement

SELECT sum(amount_sold)  
		FROM sales s, times t, promotions p 
		WHERE s.time_id  = t.time_id
		AND s.promo_id = p.promo_id 
		AND t.day_name = 'Friday' 
		AND promo_category= 'TV';
