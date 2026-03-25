select * from orders


select * from customers c
left join orders o
on c.cust_id = o.cust_id
where o.order_id is null