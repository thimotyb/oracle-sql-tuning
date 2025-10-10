REM demo23_01

select count(*) 
  from customers 
 where cust_gender='F' 
   and country_id=52771;  
   
select count(*) 
  from customers 
 where cust_gender='F' 
   and country_id=52771
   and cust_marital_status is not null;
   
select count(*) 
  from customers 
 where cust_gender='F' 
   and country_id=52771
   and (cust_marital_status is null or cust_marital_status='single');


REM One SQL

select count(*), 
       sum(decode(cust_marital_status,null,0,1)), 
       sum(decode(cust_marital_status,null,1,decode(cust_marital_status,'single',1,0)))
  from customers 
 where cust_gender='F' 
   and country_id=52771;
   
      