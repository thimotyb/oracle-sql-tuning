> SELECT 'ALTER index '||i.index_name||' VISIBLE;'
FROM   user_indexes i
WHERE  i.table_name = 'CUSTOMERS'
AND    NOT EXISTS
      (SELECT 'x'
       FROM   user_constraints c
       WHERE  c.index_name = i.index_name
       AND    c.table_name = i.table_name
       AND    c.status = 'ENABLED')
ALTER index CUST_CUST_YEAR_OF_BIRTH_BIDX VISIBLE;   
ALTER index CUST_CUST_CREDIT_LIMIT_BIDX VISIBLE;    

