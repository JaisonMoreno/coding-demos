-- SQL Query Practice - StrataScratch Examples 
 
/* 1. Find the average number of bathrooms and bedrooms for each city’s property types. 
Output the result along with the city name and the property type. */

select city, 
       property_type,
       avg(bathrooms) as avg_baths,
       avg(bedrooms) as avg_bds 
from airbnb_search_details
group by city, property_type

/* 2. Count the number of user events performed by MacBookPro users.
Output the result along with the event name.
Sort the result based on the event count in the descending order. */

select count(*) as num_events,
				   event_name
from playbook_events
where device = lower('macbook pro')
group by event_name
order by num_events desc

/* 3. Find the most profitable company from the financial sector. Output the result along with the continent. */

select company, continent
from forbes_global_2010_2014
where sector = 'Financials'
order by profits desc
limit 1

/* 4. Find the details of each customer regardless of whether the customer made an order. Output the customer's first name, last name, and the city along with the order details.
Sort records based on the customer's first name and the order details in ascending order. */

select c.first_name,
       c.last_name,
       c.city,
       o.order_details
from customers as c
left join orders as o
on c.id = o.cust_id
order by c.first_name, o.order_details

/* 5. Find order details made by Jill and Eva.
Consider the Jill and Eva as first names of customers.
Output the order date, details and cost along with the first name.
Order records based on the customer id in ascending order. */

select o.order_date,
	   o.order_details,
	   o.total_order_cost,
	   c.first_name
from orders as o
join customers as c
on o.cust_id = c.id
where first_name in ('Eva', 'Jill')
order by o.cust_id desc

/* 6. Compare each employee's salary with the average salary of the correspoding department. 
Output the department, first name, and salary of employees along with the average salary of that department. */

with dept_avg as (
    select
        department,
        avg(salary) as avg_salary
    from employee
    group by department)

select e.department,
       e.first_name, 
       e.salary, 
       d.avg_salary
from employee as e
join dept_avg as d 
on e.department = d.department
order by e.department



