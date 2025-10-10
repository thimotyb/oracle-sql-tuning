create bitmap index sales_cust_bix on sales(cust_id) local;
create bitmap index sales_prod_bix on sales(prod_id) local;
create bitmap index sales_channel_bix on sales(channel_id) local;

alter session set star_transformation_enabled=true;

alter session set tracefile_identifier='demo28_02';
alter session set sql_trace=true;

select /*+star_transformation fact(s)*/ 
       s.amount_sold,p.prod_name,ch.channel_desc
  from sales s, products p, channels ch, customers c
 where s.prod_id=p.prod_id
   and s.channel_id=ch.channel_id
   and s.cust_id=c.cust_id
   and ch.channel_id in (3, 4)
   and c.cust_city='Asten'
   and p.prod_id>100;

alter session set sql_trace=false;

drop index sales_cust_bix;
drop index sales_prod_bix;
drop index sales_channel_bix;

