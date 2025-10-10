--Connect as user sh in SQL Developer to run the statement


variable prod_id number;
variable cust_id number;
select *
from sales s1
where time_id = (select max(time_id)
                    from sales s2
                    where s1.prod_id = s2.prod_id
                    and s1.cust_id = s2.cust_id
                    and prod_id = :prod_id
                    and cust_id = :cust_id);  
