-- Create a new database 

Create database Coffee_shop_sales_dashboard
use Coffee_shop_sales_dashboard

--Data imported 

select * from Coffee_shop_sales
exec sp_help Coffee_shop_sales

--1.Total Sales Analysis
--  Calculate the total sales for each respective month
select datename(MM,transaction_date) as Month,round(SUM(transaction_qty * unit_price),2) as Total_Sales from Coffee_shop_sales 
	group by datename(MM,transaction_date),datepart(MM,transaction_date)
	order by datepart(MM,transaction_date) 

--  Determine the month on month increase or decease percenatage in sales 
select month(transaction_date) as Month,
	round(SUM(unit_price * transaction_qty),2) as Total_Sales,
	round((sum(unit_price * transaction_qty) - LAG(sum(unit_price * transaction_qty),1)
	over (order by month(transaction_date)))/LAG(sum(unit_price * transaction_qty),1) 
	over(order by month(transaction_date)) * 100,2) as 'Mom increase or decrease percentage'
from Coffee_shop_sales 
group by  month(transaction_date)

--  Calcualate the difference in sales between the selected month and previous month
select round((sum(unit_price * transaction_qty) - LAG(sum(unit_price * transaction_qty),1) over (order by month(transaction_date))),2) as 'Difference in sale for April and May'
	from Coffee_shop_sales where  month(transaction_date) in(4,5) 
	group by  month(transaction_date)

--2.Total Order Analysis
-- Calculate the total number of orders for each respective month.
select datename(mm,transaction_date) as Month,COUNT(*) as 'Total Number of Orders' from Coffee_Shop_Sales 
	group by datename(mm,transaction_date),DATEPART(mm,transaction_date)
	order by DATEPART(mm,transaction_date)

-- Determine the month on month increase or decrease in the number of orders.
select MONTH(transaction_date) as Month,count(*) as Total_orders,
	((count(*)) - lag(count(*),1) over (order by month(transaction_date))) as 'Mom increase or decrease in the number of orders' 
	from Coffee_shop_sales 
	group by  month(transaction_date)

-- Calculate the difference in the number of orders between the selceted month and the previous month
select round((COUNT(*) - LAG(COUNT(*),1) over (order by month(transaction_date))),2) as 'Difference in sale for April and May'
	from Coffee_shop_sales where  month(transaction_date) in(4,5) 
	group by  month(transaction_date)


--3.Total Quantity Sold Analysis
-- Calculate the total quantity sold for each respective month.
select datename(MM,transaction_date) as Month, SUM(transaction_qty) as 'Total Quantity Sold' from Coffee_shop_sales
	group by datename(MM,transaction_date),datepart(MM,transaction_date)
	order by datepart(MM,transaction_date)

-- Determine the month on month increase or decrease in the Total quantity sold
select month(transaction_date) as Month,
	SUM(transaction_qty) as Total_Quantity_Sales,(sum(transaction_qty) - LAG(sum(transaction_qty),1) over (order by month(transaction_date))) as 'Mom increase or decrease'
	from Coffee_shop_sales 
	group by  month(transaction_date)

-- Calculate the difference in the total quantity sold between the selceted month and the previous month
select round((sum(transaction_qty) - LAG(sum(transaction_qty),1) over (order by month(transaction_date))),2) as 'Difference in quanity sold for April and May'
	from Coffee_shop_sales where  month(transaction_date) in(4,5) 
	group by  month(transaction_date)

--4.Check total sales,total quantity sold, and total order placed for specifc date
select concat(round(SUM(unit_price * transaction_qty)/1000,1),'K') as Total_sales,SUM(transaction_qty) as Total_quantity_sold, COUNT(transaction_id) as Total_orders
	from Coffee_shop_sales where transaction_date='2023-05-18'

--5.Determine the total sales for a specific date, categorized by whether the transaction occurred on a weekend or a weekday.
select 
	case when DAY(transaction_date) in (1,7) then 'Weekend'
		else 'Weekdays'
	end as day_type,
	concat(round(SUM(unit_price * transaction_qty)/1000,2),'K') as Total_Sales from Coffee_Shop_Sales
	where transaction_date='2023-01-01'
	group by case when DAY(transaction_date) in (1,7) then 'Weekend'
				else 'Weekdays'
			 end 

--6.Determine the total sales for a specific month, categorized by whether the transaction occurred on a weekend or a weekday.
select 
	case when DAY(transaction_date) IN(1,7) then 'Weekends' 
		else 'Weekdays' 
	end as day_type,
	 concat(ROUND(sum(unit_price * transaction_qty)/1000,2),'K') as Total_Sales
	 from Coffee_Shop_Sales 
	 where MONTH(transaction_date)=5
	 group by case 
				when DAY(transaction_date) IN(1,7) then 'Weekends' 
				else 'Weekdays' 
				end

 --7.Determine the total sales for each store location for a specific month
 select store_location,CONCAT(round(sum(unit_price * transaction_qty)/1000,2),'K') as Total_Sales
	 from Coffee_shop_sales where month(transaction_date)=5
	 group by store_location
	 order by sum(unit_price * transaction_qty) desc

--8.Avg sales for a specific month
select round(AVG(Total_Sales),2) as Avg_sales from (
	select SUM(unit_price * transaction_qty) as Total_sales 
		from Coffee_Shop_Sales where MONTH(transaction_date)=5 
		group by transaction_date
	) as t2

--9.Daily sales for a specific month
select day(transaction_date) as 'Day of Month',ROUND(sum(unit_price * transaction_qty),2) as Total_sales from Coffee_Shop_Sales
	where month(transaction_date)=5
	group by day(transaction_date)
	order by day(transaction_date)

--10.Compare daily sales with average sales: if greater, label as "Above Average"; if lesser, label as "Below Average" for a specific month
select Day_of_month,Total_sales,
		case when Total_sales > avg_sales then 'Above Average'
			when Total_sales < avg_Sales then 'Below Average'
			else 'Equal to average'
			end as 'Sales Status' 
		from (
				select day(transaction_date) as Day_of_Month,ROUND(sum(unit_price * transaction_qty),2) as Total_sales,
						avg(sum(unit_price * transaction_qty)) over() as Avg_sales from Coffee_Shop_Sales
						where month(transaction_date)=5
						group by day(transaction_date)
				) as t3
		order by Day_of_Month

--11.Compare monthly sales with average sales: if greater, label as "Above Average"; if lesser, label as "Below Average" for a specific month
select Month,Total_sales,
		case when Total_sales > avg_sales then 'Above Average'
			when Total_sales < avg_Sales then 'Below Average'
			else 'Equal to average'
			end as 'Sales Status' 
		from (
				select month(transaction_date) as Month,ROUND(sum(unit_price * transaction_qty),2) as Total_sales,
						avg(sum(unit_price * transaction_qty)) over() as Avg_sales from Coffee_Shop_Sales
						group by month(transaction_date)
				) as t3
		order by Month

--12.Sales by Product category for a specific month
select product_category, ROUND(sum(unit_price * transaction_qty),2) as Total_sales from Coffee_Shop_Sales
	where MONTH(transaction_date)=5
	group by product_category
	order by Total_sales desc

--13.Top 10 products by sales for a specific month
select top 10 product_type, ROUND(sum(unit_price * transaction_qty),2) as Total_sales from Coffee_Shop_Sales
	where MONTH(transaction_date)=5
	group by product_type
	order by Total_sales desc

--14.Sales by given Day and Hour
select ROUND(sum(unit_price * transaction_qty),2) as Total_sales,SUM(transaction_qty) as Total_quantity, COUNT(*) as Total_orders
	from Coffee_Shop_Sales
	where DATEPART(WEEKDAY, transaction_date) = 3 
		  AND DATEPART(HOUR, transaction_time) = 8
		  AND MONTH(transaction_date) = 5

--15.To get sales for all hours for a specific month
select DATEPART(hour,transaction_time) as Hours_of_the_day, ROUND(sum(unit_price * transaction_qty),2) as Total_sales from Coffee_Shop_Sales
	where MONTH(transaction_date)=5
	group by DATEPART(hour,transaction_time) 
	order by DATEPART(hour,transaction_time) 


--16.To get sales from Monday to Sunday for a specific month
select case
			when DAY(transaction_date) = 2 then 'Monday'
			when DAY(transaction_date) = 3 then 'Tuesday'
			when DAY(transaction_date) = 4 then 'Wednesday'
			when DAY(transaction_date) = 5 then 'Thursday'
			when DAY(transaction_date) = 6 then 'Friday'
			when DAY(transaction_date) = 7 then 'Saturday'
			else 'Sunday'
	end as Day_of_week ,ROUND(sum(unit_price * transaction_qty),2) as Total_sales
	from Coffee_Shop_Sales where MONTH(transaction_date)=5
	group by 
		case
			when DAY(transaction_date) = 2 then 'Monday'
			when DAY(transaction_date) = 3 then 'Tuesday'
			when DAY(transaction_date) = 4 then 'Wednesday'
			when DAY(transaction_date) = 5 then 'Thursday'
			when DAY(transaction_date) = 6 then 'Friday'
			when DAY(transaction_date) = 7 then 'Saturday'
			else 'Sunday'
		end,datepart(DD,transaction_date)
	order by datepart(DD,transaction_date)

---End of Project 






