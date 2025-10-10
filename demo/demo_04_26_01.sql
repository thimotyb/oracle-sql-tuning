WITH sales_numbers AS
( SELECT s.prod_id, s.amount_sold, t.week_ending_day
  FROM sales s
  , times t
  , products p
  WHERE s.time_id = t.time_id
  AND s.prod_id = p.prod_id
  AND p.prod_category = 'Photo'
  AND p.prod_name LIKE '%Memory%'
  AND t.week_ending_day BETWEEN TO_DATE('01-JUL-2001','dd-MON-yyyy') 
                            AND TO_DATE('16-JUL-2001','dd-MON-yyyy')
)
, product_revenue AS 
( SELECT p.prod_name product, s.week_ending_day, SUM(s.amount_sold) revenue
  FROM products p
    LEFT OUTER JOIN (SELECT prod_id, amount_sold, week_ending_day 
                     FROM sales_numbers) s
    ON (s.prod_id = p.prod_id)
  WHERE p.prod_category = 'Photo'
  AND p.prod_name LIKE '%Memory%'
  GROUP BY p.prod_name, s.week_ending_day
)
, weeks AS
( SELECT distinct week_ending_day week FROM times WHERE week_ending_day
  BETWEEN TO_DATE('01-JUL-2001','dd-MON-yyyy') 
  AND TO_DATE('16-JUL-2001','dd-MON-yyyy')
)
, complete_product_revenue AS
( SELECT w.week, pr.product, nvl(pr.revenue,0) revenue
  FROM product_revenue pr
    PARTITION BY (product)
    RIGHT OUTER JOIN weeks w
    ON (w.week = pr.week_ending_day)
)
SELECT week
, product
, TO_CHAR(revenue,'L999G990D00') revenue
, TO_CHAR(revenue - lag(revenue,1) OVER (PARTITION BY product 
     ORDER BY week),'L999G990D00') w_w_diff
, TO_CHAR(100 * RATIO_TO_REPORT(revenue) OVER (PARTITION BY week),'990D0') percentage
FROM complete_product_revenue
ORDER BY week, product;