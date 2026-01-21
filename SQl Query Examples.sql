-- SQL Query Practice - StrataScratch Examples. 
-- Easy --> Medium --> Difficult
 
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


/* 7. Meta/Facebook has developed a new programming language called Hack. To measure the popularity of Hack they ran a survey with their employess. 
The survey included data on previous programming familiarity as well as the number of years of experience, age, gender and most popularity of Hack
by office location. Luckily the user IDs of employees completing the surveys were stored.
Based on the above, find the average popularity of the Hack per office location. 
Output the location along with the average popularity. */

--select * from facebook_employees;
--select * from facebook_hack_survey;

select e.location, AVG(popularity) as avg_pop --s.employee_id, e.id
from facebook_hack_survey as s
join facebook_employees as e
on s.employee_id = e.id
group by e.location
order by avg_pop


/* 8. Find the last time each bike was in use. Output both the bike number and the date-timestamp of the bike's last use (ie, the date-time the bike was returned).
Order the results by bikes that were most recently used. */

select bike_number, max(end_time) as last_used
from dc_bikeshare_q1_2012
group by bike_number
order by last_used desc

/* 9. We have a table with employees and their salaries, however, some of the records are old and contain outdated salary information. Find the current salary of each employee
assuming that salaries increase each year. Output their id, first name, last name, department ID, and current salary. Order your list by employee ID in ascending order.  */

--select * from ms_employee_salary;
select id, first_name, last_name, department_id, salary
from (
select *, row_number() over (
            partition by id
            order by salary desc, department_id desc
            ) 
        from ms_employee_salary
) 
where row_number = 1
order by id 
