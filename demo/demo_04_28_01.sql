alter session set tracefile_identifier='demo28_01';
alter session set sql_trace=true;

select s.amount_sold,p.prod_name,ch.channel_desc
  from sales s, products p, channels ch, customers c
 where s.prod_id=p.prod_id
   and s.channel_id=ch.channel_id
   and s.cust_id=c.cust_id
   and ch.channel_id in (3, 4)
   and c.cust_city='Asten'
   and p.prod_id>100;

alter session set sql_trace=false;

