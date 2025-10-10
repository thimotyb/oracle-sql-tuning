--Connect as user sh in SQL Developer to run the statement

SELECT s.prod_id, s.amount_sold, t.week_ending_day 
    FROM sales s , times t , products p 
    WHERE s.time_id = t.time_id AND s.prod_id = p.prod_id  
    AND p.prod_category = 'Photo' 
    AND p.prod_name LIKE '%Memory%' 
    AND t.week_ending_day BETWEEN TO_DATE('01-JUL-2001','dd-MON-yyyy') 
    AND TO_DATE('16-JUL-2001','dd-MON-yyyy');
