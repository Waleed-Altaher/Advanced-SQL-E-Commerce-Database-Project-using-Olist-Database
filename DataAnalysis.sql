
--1: What is the distribution of seller ratings on Olist?
select case when review_score= 5 then 'Excellent'
			when review_score= 4 then 'Very good'
			when review_score= 3 then 'Good'
			when review_score= 2 then 'Bad'
			when review_score= 1 then 'Very bad'
			end as rating,
			count(o.order_id) as num_order, round(sum(op.payment_value),2) as total_value 


from olist_orders o inner join olist_order_reviews ore on o.order_id=ore.order_id
inner join olist_order_payments op on o.order_id=op.order_id
inner join olist_order_items oi on  o.order_id=oi.order_id
and  order_status!='canceled' and op.payment_value is not null
group by review_score 
order by review_score desc 



--2:create view to show Which product categories have the highest profit margins on Olist?
create view highest_profit_margin
as
select top(10)op.product_category_name_english ,ROUND(sum(opay.payment_value)-sum(oi.price)
+sum(oi.freight_value)/sum(opay.payment_value) *100,2) as margin_profit
from  olist_orders o inner join olist_order_items oi on o.order_id=oi.order_id
inner join olist_order_payments opay on o.order_id=opay.order_id
inner join olist_products op on op.product_id=oi.product_id
group by op.product_category_name_english
order by margin_profit desc

select * from highest_profit_margin

--3-create trigger to prevent any one to update or change price on table olist_order_items and return  
--username , ModifiedDate and old value and newvalue of price 

create table history1
(
order_id varchar(50),
UserName varchar(50),
ModifiedDate datetime,
oldprice	float,
newprice   float
)
create or alter trigger t1
on olist_order_items
instead of update
as
	if(update(price))
	begin
	declare @order_id varchar(50) 
	declare @newprice float ,@oldprice float
	select @order_id=order_id from olist_order_items
	select @newprice=price from inserted
	select @oldprice=price from deleted
	insert into history1
	values(@order_id,SUSER_NAME(),GETDATE(),@oldprice,@newprice)
	end
	
update olist_order_items
set price=60
where order_id='008720830a8a30e39e6f22f81818a141' and order_item_id=1 

select * from history1

--4-create trigger to prevent any one to update or change payment value on table olist_order_payments
--and return username , ModifiedDate and old value and newvalue 

create table history2
(
order_id int,
UserName varchar(20),
ModifiedDate date,
oldpayment_value	int,
newpayment_value   int
)
create trigger t2
on olist_order_payments
instead of update
as
	if(update(payment_value))
	begin
	declare @order_id int 
	declare @newpayment_value int ,@oldpayment_value int
	select @order_id=order_id from olist_order_items
	select @newpayment_value=payment_value from inserted
	select @oldpayment_value=payment_value from deleted
	insert into history2
	values(@order_id,SUSER_NAME(),GETDATE(),@newpayment_value,@oldpayment_value)
	end
	select * from history2

--5-What is the average customer rating for products sold on Olist?
select product_category_name_english ,avg(orev.review_score) as avg_score ,sum(opay.payment_value) as total_rev,
round(sum(opay.payment_value)/count(distinct o.order_id),2) as avg_rev
from olist_orders o inner join olist_order_reviews orev on o.order_id=orev.order_id
 inner join olist_order_items oi on o.order_id=oi.order_id
 inner join olist_products op on op.product_id=oi.product_id
inner join olist_order_payments opay on o.order_id=opay.order_id
where order_status!='canceled' and order_approved_at is not null
group by  product_category_name_english
order by total_rev


--6-How many customers have made repeat purchases on Olist?
select count(*) as repeat_purchases
from (select distinct customer_unique_id,order_status,count (distinct order_id) as num_order
from olist_orders  o inner join olist_customers oc on  oc.customer_id=o.customer_id
group by customer_unique_id,order_status
having count( order_id)>1 )sub;

--7-What are the top 10 popular product categories on Olist, and what are their sales volumes?
create or alter view Top_ten_Popular_product_categories(Category_name, No_prodcut_sold, Revenue)
with encryption
as
	select top(10) pr.product_category_name_english, count(pr.product_category_name_english) as Category_Count, round(sum(py.payment_value), 2) as Revenue
	from olist_products pr, olist_order_items oi, olist_orders ord, olist_order_payments py
	where oi.product_id = pr.product_id and 
	ord.order_id = oi.order_id and 
	py.order_id = ord.order_id and 
	ord.order_status not in ('canceled', 'unavailable')
	group by product_category_name_english
	order by Category_Count desc

select * from Top_ten_Popular_product_categories


--8-What is the average order value (AOV) on Olist, and how does this vary by product category?
create or alter view Average_order_value(Category, Average_Order_Value, Total_Average)
with encryption
as
	select pr.product_category_name_english, round(avg(pay.payment_value), 2), (select round(avg(payment_value), 2) from olist_order_payments) 
	from olist_order_payments pay, olist_orders orders, olist_order_items items, olist_products pr
	where orders.order_id = pay.order_id and
	items.order_id = orders.order_id and 
	pr.product_id = items.product_id and 
	orders.order_status not in ('canceled', 'unavailable')
	group by product_category_name_english

select * from Average_order_value order by Category desc


--9-SP to get best sellers based on some criteria like last number of days, number of products, the seller list for customers, number od orders sold, and average scores of orders.
create or alter proc Best_Sellers @days int, @no_products int, @no_orders int, @average_score int
as
	select slr.seller_id, count(distinct ord.order_id) as orders
		from olist_sellers slr, olist_order_items itm, olist_orders ord, olist_order_reviews rvu
		where itm.seller_id = slr.seller_id and 
		ord.order_id = itm.order_id and 
		rvu.order_id = ord.order_id and 
		ord.order_status not in ('canceled', 'unavailable')
		group by slr.seller_id
		having DATEDIFF(day, min(ord.order_purchase_timestamp), max(ord.order_purchase_timestamp))>= @days and
		count(itm.product_id) >= @no_products and 
		count(distinct ord.order_id) >= @no_orders and
		avg(rvu.review_score) >= @average_score
		order by orders desc

Best_Sellers 30, 20, 10, 5;

--10-Function to get the number of products sold by category and city
create or alter function No_products_by_category_and_city( @category varchar(50), @city varchar(30))
returns int 
	begin
	declare @number int
	select @number=count(prod.product_id) from region rg, olist_customers cust, olist_orders ord, olist_order_items itm, olist_products prod
	where cust.zip_code = rg.zip_code and
	ord.customer_id = cust.customer_id and
	itm.order_id = ord.order_id and
	prod.product_id = itm.product_id and
	ord.order_status not in ('canceled', 'unavailable') and
	prod.product_category_name_english = @category  and
	rg.city = @city
	return @number
	end

select dbo.No_products_by_category_and_city('home_appliances', 'santo andre') as No_products_Sold


--11-View to get best customers by revenue
create or alter view Best_customers_by_revenue(Customer, Revenue)
with encryption
as
	select cust.customer_id , sum(pay.payment_value) 
	from olist_customers cust, olist_orders ord, olist_order_payments pay
	where ord.customer_id = cust.customer_id and
	pay.order_id = ord.order_id and
	ord.order_status not in ('canceled', 'unavailable')
	group by cust.customer_id

select * from Best_customers_by_revenue order by Revenue desc




--12-What is the total revenue generated by Olist,  how is revenue changed over time?

(select year(order_purchase_timestamp) over_year , DATEPART(QUARTER,order_purchase_timestamp) over_quarter ,
format(sum( payment_value), '#,###,###') revenue from olist_order_payments op 
inner join olist_orders oo on oo.order_id = op.order_id
where order_status != 'canceled'  

group by year(order_purchase_timestamp), DATEPART(QUARTER,order_purchase_timestamp))
union all

select min(year(order_purchase_timestamp)), max(year(order_purchase_timestamp)) , format(sum( payment_value), '#,###,###') revenue 
from olist_order_payments op 
inner join olist_orders oo on oo.order_id = op.order_id
where order_status != 'canceled'  

order by over_year desc , over_quarter asc

--13-check average reviews of a category name for a chosen name/ 
create function Get_Cat_review (@x varchar(20))
returns table 
as return 
select * from 
(select product_category_name_english , avg (review_score) average_review_for_cat
from olist_products op 
join olist_order_items ooi on op.product_id = ooi.product_id
join olist_order_reviews oor on oor.order_id = ooi.order_id 
group by product_category_name_english) final
where final.product_category_name_english = @x

select * from Get_Cat_review ('auto')/--ex: auto , housewares, watches_gifts/

--14-What is the average order cancellation rate on Olist?

select order_status, count(order_id) as num  , round(count(order_id)/sum(count(order_id)) over(), 2) as percentage 
from olist_orders 
where order_status = 'canceled'
group by order_status






