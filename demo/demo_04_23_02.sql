         
REM demo23_02

select sum(amount_sold) 
  from sales
 where prod_id = 47
   and time_id between to_date('20010101','yyyymmdd') and to_date('20011231', 'yyyymmdd')
   and channel_id = 2;

select avg(amount_sold)
  from sales
 where prod_id = 47
   and time_id between to_date('20010101','yyyymmdd') and to_date('20011231', 'yyyymmdd')
   and amount_sold < 29;
   
   
REM One SQL
   
select sum(decode(channel_id, 2, amount_sold, 0)), 
       sum(decode(sign(amount_sold - 29), -1, amount_sold, 0)) / sum(decode(sign(amount_sold - 29), -1, 1, 0))
  from sales
 where prod_id = 47
   and time_id between to_date('20010101','yyyymmdd') and to_date('20011231', 'yyyymmdd');


   
