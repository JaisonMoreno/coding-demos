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

/* 10. Calculates the difference between the highest salaries in the marketing and engineering departments. Output just the absolute difference in salaries. */
select abs(
			max(case when d.department= 'marketing' then e.salary end) - 
            max(case when d.department= 'engineering' then e.salary end)) as salary_diff
from db_employee as e
join db_dept as d 
on e.department_id = d.id
where d.department in ('marketing', 'engineering');

/* 11. Management wants to analyze only employees with official job titles. Find the job titles of the employees with the highest salary. If multiple employees have the same highest salary, include all their job titles.*/

select t.worker_title as best_paid_titles
from title as t
join worker as w
on w.worker_id = t.worker_ref_id
where w.salary = 
    (select max(a.salary) 
     from worker as a
     join title as b
     on a.worker_id = b.worker_ref_id
     where b.worker_title is not null)
	 
/* 12. Return the total number of comments received for each user in the 30-day period up to and including 2020-02-10. Don't output users who haven't received any comment in the defined time period. */
select user_id, sum(number_of_comments) as num_of_comments
from fb_comments_count
where created_at between '2020-01-11' and '2020-02-10'
group by user_id
having sum(number_of_comments) > 0
order by sum(number_of_comments)

/* 13. Return the total number of posts for each month, aggregated across all the years (i.e., posts in January 2019 and January 2020 are both combined into January). Output the month number (i.e., 1 for January, 2 for February) and the total number of posts in that month.*/
select month(post_date) as month, count(*) as count_of_posts
from facebook_posts
group by month(post_date)
order by month

/* 14. How many paid users had any calls in Apr 2020? */
SELECT COUNT(DISTINCT u.user_id)
FROM rc_users AS u
INNER JOIN rc_calls AS c
    ON u.user_id = c.user_id
WHERE
    MONTH(call_date) = 4 AND YEAR(call_date) = 2020
    AND
    status = 'paid'

/* 15. Return a list of users with status free who didn't make any calls in APr 2020 */

select distinct u.user_id
from rc_users as u
left join rc_calls as c
on u.user_id = c.user_id
and
c.call_date between '2020-04-01' and '2020-04-30'
where u.status = 'free' 
    and 
c.user_id is null


/* 16. Write a query that returns the number of unique users per client for each month. Assume all events occur within the same year, so only month needs to be be in the output as a number from 1 to 12. */

select month(time_id) as month, client_id, count(distinct user_id) as unique_users  
from fact_events
group by month(time_id), client_id
order by month(time_id)

/* 17. Find the number of unique transactions and total sales for each of the product categories in 2017. Output the product categories, number of transactions, and total sales in descending order. The sales column represents the total cost the customer paid for the product so no additional calculations need to be done on the column.
Only include product categories that have products sold. */

select count(distinct t.transaction_id) as transactions, sum(t.sales) as tot_sales, p.product_category
from wfm_transactions as t
join wfm_products as p
on t.product_id = p.product_id
where year(t.transaction_date) = 2017 and p.product_category is not null
group by p.product_category
order by p.product_category, tot_sales desc