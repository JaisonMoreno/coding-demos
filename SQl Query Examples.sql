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

/* 18. Return all employees who have never had an annual review. Your output should include the employee's first name, last name, hiring date, and termination date. List the most recently hired employees first. */
select e.first_name, e.last_name, e.hire_date, e.termination_date
from  uber_employees as e
left join uber_annual_review as r
on e.id=r.emp_id
where r.emp_id is null
order by e.hire_date desc

/* 19. Uber is interested in identifying gaps in their business. Calculate the count of orders for each status of each service. Your output should include the service name, status of the order, and the number of orders. */
select service_name, status_of_order, sum(number_of_orders) as ct
from uber_orders
group by service_name, status_of_order
order by service_name, status_of_order

/* 20. Find the monthly active users for January 2021 for each account. Your output should have account_id and the monthly count for that account.*/
select account_id, count(distinct user_id)
from sf_events
where year(record_date) = 2021 and month(record_date) = 1
group by account_id
order by account_id

/* 21. Write a query that will calculate the number of shipments per month. The unique key for one shipment is a combination of shipment_id and sub_id. Output the year_month in format YYYY-MM and the number of shipments in that month. */
select count(concat(shipment_id,'-', sub_id)) as num_shipments, format(shipment_date, 'yyyy-MM') as year_month
from amazon_shipment
group by format(shipment_date, 'yyyy-MM')

/* 22. Write a query to find the weight for each shipment's earliest shipment date. Output the shipment id along with the weight. */
with cte as (
select shipment_id, weight, shipment_date,
row_number() over(
partition by shipment_id
order by shipment_date asc
)  as rn
from amazon_shipment
)
select shipment_id, weight
from cte
where rn=1

-- OR

WITH cte AS
  (SELECT shipment_id,
          MIN(shipment_date) AS min_date
   FROM amazon_shipment
   GROUP BY shipment_id)
SELECT cte.shipment_id,
       weight
FROM amazon_shipment
JOIN cte ON amazon_shipment.shipment_id = cte.shipment_id
WHERE min_date = shipment_date


/* 23. Calculate the total weight for each shipment and add it as a new column. Your output needs to have all the existing rows and columnn in addition to the new column that shows the total weight for each shipment. One shipment can have multiple rows. */
with cte as (
select shipment_id, sum(weight) as total_weight
from amazon_shipment
group by shipment_id
) 
select s1.shipment_id, s1.sub_id, s1.weight,s1.shipment_date, cte.total_weight
from amazon_shipment as s1
join cte
on s1.shipment_id=cte.shipment_id

/* 24. Count the number of users who made more than 5 searches in August 2021 */
with cte as (
select count(user_id) as tot_count, user_id
from fb_searches
where month(date)=8 and year(date)=2021
group by user_id
having count(user_id)>5
)
select count(distinct user_id) from cte

--OR

SELECT COUNT(user_id) AS result
FROM
  (SELECT user_id,
          COUNT(search_id) AS august_searches
   FROM fb_searches
   WHERE date BETWEEN '2021-08-01' AND '2021-08-31'
   GROUP BY user_id) a
WHERE august_searches > 5;

/* 25. How many searches were there in the second quarter of 2021? */
select count(search_id) as tot_searches
from fb_searches
where month(date) in (4,5,6) and year(date)=2021


-- OR

SELECT COUNT(search_id) AS RESULT
FROM fb_searches
WHERE DATEPART(QUARTER, date) = 2
  AND YEAR(date) = 2021

-- Postgres SQL:
SELECT count(search_id) AS RESULT
FROM fb_searches
WHERE extract(QUARTER
              FROM date) = 2
  AND extract(YEAR
              FROM date) = 2021

/* 26. You are given a list of exchange rates from various currencies to US Dollars (USD) in different months. Show how the exchange rate of all the currencies changed in the first half of 2020. Output the currency code and the difference between values of the exchange rate between July 1, 2020 and January 1, 2020. */
-- using lag function and cte
with cte as (
select  source_currency,
        exchange_rate,
        date,
        exchange_rate - lag(exchange_rate, 1,0) over (partition by source_currency order by date) as difference
from sf_exchange_rate
where month(date) in (1,7) and year(date)=2020
)
select source_currency, difference
from cte
where date = '2020-07-01'

--OR

select jan.source_currency, jul.exchange_rate - jan.exchange_rate as diff
from sf_exchange_rate as jan
join sf_exchange_rate as jul 
on jan.source_currency = jul.source_currency
where jan.date = '2020-01-01' and jul.date='2020-07-01'

/* 27. What percentage of all products are both low fat and recyclable? */ 
-- ms sql server
select sum(case
            when is_low_fat = 'Y'
            and is_recyclable = 'Y' then 1
            else 0
            end) / cast(count(*) as float) * 100 as percentage
from facebook_products

-- postgres
SELECT SUM(CASE
               WHEN is_low_fat = 'Y'
                    AND is_recyclable = 'Y' THEN 1
               ELSE 0
           END) / COUNT(*)::float * 100.0 as percentage
FROM facebook_products

/* 28. The marketing manager wants you to evaluate how well the previously ran advertising campaigns are working.
Particularly, they are interested in the promotion IDs from the online_promotions table.
Calculate the percentage of orders in the online_orderstable that used a promotion from the online_promotions table. */
select (cast(count(p.promotion_id) as float)/count(*)) * 100 as percentage --count(*) as tot, count(p.promotion_id) as num_prom 
from online_orders as o
left join online_promotions as p
on o.promotion_id = p.promotion_id


/* 29. For each platform (e.g. Windows, iPhone, iPad etc.), calculate the number of users. Count the number of distinct users per platform, regardless of whether they used other platforms. Output the name of the platform with the corresponding number of users. */
select platform, count(distinct user_id) as num_users
from user_sessions
group by platform
order by platform

/* 30. Count how many claims submitted in Dec 2021 are still pending. A claim is pending when it has neither an acceptance nor rejection date. */
select count(*) as pending
from cvs_claims
where date_accepted is NULL and date_rejected is NUll
and extract(year from date_submitted) = 2021 and extract(month from date_submitted)=12


/* 31. For each video game player, find the latest date when they logged in. */
with cte as (
select player_id, login_date, row_number() over (partition by player_id order by login_date desc) as rn
from players_logins
)
select  player_id, login_date
from cte 
where rn = 1

-- or can use max() func to simplify
select player_id, max(login_date)
from players_logins
group by player_id;

/* 32. Given the education levels and salaries of a group of individuals, find what is the average salary for each level of education. */
select education, avg(cast(salary as float)) as avg_salary
from google_salaries
group by education
order by avg_salary desc

/* 33. Write a query to return all Customers (cust_id) who are violating primary key constraints in the Customer Dimension (dim_customer) i.e. those Customers who are present more than once in the Customer Dimension.
For example if cust_id 'C123' is present thrice then the query should return two columns, value in first should be 'C123', while value in second should be 3  */
select cust_id, count(cust_id) as num
from dim_customer
group by cust_id
having count(cust_id)>=2

/* 34. Write a query to get a list of products that have not had any sales. Output the ID and market name of these products. */
select p.prod_sku_id as salesid, market_name
from dim_product as p
left join fct_customer_sales as s
on s.prod_sku_id=p.prod_sku_id
where s.prod_sku_id is null
order by market_name

/* 35. How many orders were shipped by Speedy Express in total? */
select count(*) as num_orders
from shopify_orders
join shopify_carriers
on shopify_orders.carrier_id = shopify_carriers.id
where lower(name) = 'speedy express'


/* 36. Find the number of account registrations according to the signup date. Output the year months (YYYY-MM) and their corresponding number of registrations. */
select count(*) as ct,  format(started_at, 'yyyy-MM') as year_month  --count(signup_id), format(started_at, 'yyyy-mm') as year_month
from noom_signups
group by format(started_at, 'yyyy-MM')
order by year_month

/* 37. Calculate the sales revenue for the year 2021. */
select sum(order_total) as revenue
from amazon_sales
where extract(year from order_date) = 2021

/* 38. You are given a list of posts of a Facebook user. Find the average number of likes */
select avg(cast(no_of_likes as float)) as avg_likes
from fb_posts

/* 39. Amazon's information technology department is looking for information on employees' most recent logins.
The output should include all information related to each employee's most recent login. */
with cte as (
select worker_id, max(login_timestamp) as last_login 
from worker_logins
group by worker_id
)
select worker_logins.* 
from worker_logins
join cte
on worker_logins.worker_id = cte.worker_id and
worker_logins.login_timestamp = cte.last_login

-- or using rank 
WITH cte AS
  (SELECT worker_id,
          login_timestamp,
          RANK() OVER(PARTITION BY worker_id
                      ORDER BY login_timestamp DESC) AS rnk
   FROM worker_logins)
SELECT w.*
FROM worker_logins w
JOIN cte c ON w.worker_id = c.worker_id
AND w.login_timestamp = c.login_timestamp
WHERE c.rnk = 1

/* 40. You've been asked by Amazon to find the shipment_id and weight of the third heaviest shipment.
Output the shipment_id, and total_weight for that shipment_id.
In the event of a tie, do not skip ranks.*/
with cte as (
select shipment_id, 
sum(weight) as total_weight,
--rank() over(order by sum(weight) desc) as rnk,
dense_rank() over(order by sum(weight) desc) as dnsrnk
--row_number() over(order by sum(weight) desc) as rnum
from amazon_shipment
group by shipment_id
) 
select shipment_id, total_weight
from cte
where dnsrnk=3

/* 41. You have been asked to find the number of employees hired between the months of January and July in the year 2022 inclusive.
Your output should contain the number of employees hired in this given time frame. */
select count(*)
from employees
where joining_date between '2022-01-01' and '2022-07-31'


/* 42. You have been tasked with finding the worker IDs of individuals who logged in between the 13th to the 19th inclusive of December 2021.
In your output, provide the unique worker IDs for the dates requested. */
select distinct(worker_id)
from worker_logins
where year(login_timestamp)=2021 and 
day(login_timestamp) between 13 and 19
order by worker_id

/* 43. The sales division is investigating their sales for the past month in Oregon.
Calculate the total revenue generated from Oregon-based customers for April 2022. */
select sum(o.cost_in_dollars * o.units_sold) as revenue
from online_orders as o
join online_customers as c
on o.customer_id=c.id
where lower(c.state) = 'oregon' and year(date_sold)=2022 and month(date_sold)=4

/* 44. You have been asked to sort movies according to their duration in descending order.
Your output should contain all columns sorted by the movie duration in the given dataset.*/
-- ms sql
select *
from movie_catalogue
order by try_cast(replace(duration, 'min', '') as int) desc, title

--postgres
SELECT *
FROM movie_catalogue
ORDER BY CAST(regexp_replace(duration, '[^0-9]+', '') AS DECIMAL) DESC;

/* 45. You've been asked to arrange a column of random IDs in ascending alphabetical order based on their second character. */
select id
from random_id
order by substring(id, 2,1) 

/* 46. Find SAT scores of students whose high school names do not end with 'HS'. */
select * 
from sat_scores
where right(school, 2)<>'HS'

/* 47. Find hotels in the Netherlands that got complaints from guests about room dirtiness (word "dirty" in its negative review). Output all the columns in your results */
select * from hotel_reviews
where lower(negative_review) LIKE '%dirty%' and
lower(hotel_address) LIKE '%netherlands%'

/* 48. Find the date when Apple's opening stock price reached its maximum */
select date 
from aapl_historical_stock_price
where open = (select max(open) from aapl_historical_stock_price)

--
select date 
from aapl_historical_stock_price
order by open desc
limit 1

/* 49. Find the search details for apartments where the property type is Apartment and the accommodation is suitable for one person.*/
select * 
from airbnb_search_details
where lower(property_type) = 'apartment' and
accommodates = 1

/* 50. Find all searches for accommodations where the number of bedrooms is equal to the number of bathrooms.*/
select * 
from airbnb_search_details
where bedrooms = bathrooms

/* 51. Find distinct searches for Los Angeles neighborhoods. Output neighborhoods and remove duplicates.*/
select distinct neighbourhood
from airbnb_search_details
where upper(city) = 'LA' 
and neighbourhood is not null
order by neighbourhood


/* 52. Find the search details for villas and houses with wireless internet access.*/
select *
from airbnb_search_details
where lower(property_type) in ('villa', 'house')
and lower(amenities) like '%wireless internet%'

/* 53. Find all search details where data is missing from the host_response_rate column.*/
select * 
from airbnb_search_details
where host_response_rate is null

/* 54. Find all searches for San Francisco with a flexible cancellation policy and a review score rating. Sort the results by the review score in the descending order. */
select * 
from airbnb_search_details
where upper(city) = 'SF'
and lower(cancellation_policy) = 'flexible' 
and review_scores_rating is not null
order by review_scores_rating desc

---------------------- MEDIUM DIFFICULTY ------------------------------
/* 1.  Write a query that returns a table containing the number of signups for each weekday and for each billing cycle frequency. The day of the week standard we expect is from Sunday as 0 to Saturday as 6.
Output the weekday number (e.g., 1, 2, 3) as rows in your table and the billing cycle frequency (e.g., annual, monthly, quarterly) as columns. If there are NULLs in the output replace them with zeroes. */

set datefirst 7
select datepart(weekday, s.signup_start_date) - 1 as weekday,
sum(IIF(billing_cycle = 'annual', 1, 0 )) as annual,
sum(IIF(billing_cycle = 'monthly', 1, 0)) as monthly,
sum(IIF(billing_cycle = 'quarterly', 1,0)) as quarterly
from signups as s
join plans as p
on s.plan_id = p.id
group by datepart(weekday, s.signup_start_date) - 1

-- OR

select 
datepart(weekday, signup_start_date) -1 as weekday,
sum(case when billing_cycle = 'annual'then 1 else 0 end) as annual, 
sum(case when billing_cycle = 'monthly'then 1 else 0 end) as monthly, 
sum(case when billing_cycle = 'quarterly'then 1 else 0 end) as quarterly
from signups as s
join plans as p
on s.plan_id = p.id
group by datepart(weekday, s.signup_start_date) - 1

-- Postgres
select extract(dow from signup_start_date) as weekday,
sum(case when billing_cycle = 'annual' then 1 else 0 end) as annual,
sum(case when billing_cycle = 'monthly' then 1 else 0 end) as monthly,
    sum(case when billing_cycle = 'quarterly' then 1 else 0 end) as quarterly
from signups as s
join plans as p
on s.plan_id = p.id
group by extract(dow from signup_start_date)

/* 2. Calculate the churn rate of September 2021 in percentages. The churn rate is the difference between the number of customers on the first day of the month and on the last day of the month, divided by the number of customers on the first day of a month.
Assume that if customer's contract_end is NULL, their contract is still active. Additionally, if a customer started or finished their contract on a certain day, they should still be counted as a customer on that day. */
with cte as (
select user_id, 
(case when contract_start <= '2021-09-01' then 1 end) as client,
(case when contract_end>= '2021-09-30' or contract_end is null then 1 end) as churn
from natera_subscriptions
)
select 100 *  (sum(client) - sum(churn))/sum(client) as churn
from cte
where client is not null

/* 3. Calculate and display the minimum, average and the maximum number of days it takes to process a refund for accounts opened from January 1, 2019. Group by billing cycle in months.
Note: The time frame for a refund to be fully processed is from settled_at until refunded_at. */
select p.billing_cycle_in_months as billing_cycle,
       min(datediff(day, settled_at, refunded_at)) as min_days,
       avg(cast(datediff(day, settled_at, refunded_at) as float)) as avg_days,
       max(datediff(day, settled_at, refunded_at)) as max_days
from noom_transactions as t
join noom_signups as s
    on t.signup_id = s.signup_id
join noom_plans as p
    on s.plan_id = p.plan_id
where s.started_at >= '2019-01-01'
group by p.billing_cycle_in_months

/* 4. You have been asked to calculate the average age by gender of people who filed more than 1 claim in 2021.
The output should include the gender and average age rounded to the nearest whole number. */

with cte as (
select c.account_id, count(*) as num_claims
from cvs_claims as c
join cvs_accounts as a
on c.account_id = a.account_id
where year(date_submitted) = 2021 
group by c.account_id
)

select gender, avg(age)
from cvs_claims as c
join cvs_accounts as a
    on c.account_id = a.account_id
join cte 
    on c.account_id=cte.account_id
where num_claims>1
group by gender

/* 5. Write a SQL query to show each loan and its rate type. For each loan, create two new columns: fixed and variable. If the loan has a fixed rate, put a 1 in the fixed column and a 0 in the variable column. If the loan has a variable rate, do the opposite. */
select loan_id, 
(case when lower(rate_type) = 'variable' then 1 else 0 end) as variable,
(case when lower(rate_type) = 'fixed' then 1 else 0 end) as fixed
from submissions
order by loan_id

/* 6. Write a query that returns the rate_type, loan_id, loan balance , and a column that shows with what percentage the loan's balance contributes to the total balance among the loans of the same rate type. Sort the final output by rate_type and loan_id. */
with cte as (
select rate_type, sum(balance) as total_balance
from submissions
group by rate_type
)
select s.rate_type, s.loan_id, s.balance, (s.balance/cte.total_balance) * 100 as percentage
from submissions s
join cte 
on cte.rate_type = s.rate_type

--OR

select rate_type, loan_id, balance,  100 * (balance / sum(balance) over(partition by rate_type)) as percentage
from submissions

/* 7. Write a query to return the total loan balance for each user based on their most recent "Refinance" submission. The submissions table joins to the loans table using loan_id from submissions and id from loans. */
with cte as (
select
l.user_id, balance,
row_number() over(partition by user_id order by created_at desc) as rn
from loans l
join submissions s
    on l.id = s.loan_id
where type = 'Refinance'
)

select user_id,	balance
from cte
where rn=1

/* 8. Calculate the percentage of users who are both from the US and have an 'open' status, as indicated in the fb_active_users table. */
select 100 * (
                cast(count(*) filter(where country = 'USA' and lower(status)='open') as float) /
                cast(count(*) as float)
            )
from fb_active_users

-- OR
select 
sum(case when status = 'open' and country='USA' then 1 else 0 end) * 100.0 /
count(*)
from fb_active_users

/* 9. List the top 3 users who accumulated the most sessions. Include only the user who had more streaming sessions than viewing. Return the user_id, number of streaming sessions, and number of viewing sessions. */
with 
cte1 as (
select user_id, count(*) as sessions
from twitch_sessions
group by user_id
),
cte2 as (
select user_id,
sum(case when lower(session_type) = 'streamer' then 1 else 0 end) as streams,
sum(case when lower(session_type) = 'viewer' then 1 else 0 end) as views
from twitch_sessions
group by user_id
having sum(case when lower(session_type) = 'streamer' then 1 else 0 end) >
       sum(case when lower(session_type) = 'viewer' then 1 else 0 end)
) 

select top 3 
cte2.user_id, streams, views
from cte2 
join cte1  
    on cte1.user_id=cte2.user_id
order by sessions desc

/* 10. Which hour of the day has the highest average number of orders across all recorded days? Your output should include the hour that satisfies this condition and the corresponding average number of orders per hour. The "order volume" refers to the count of orders placed within each hour of the day. */
with cte as (
select cast(order_timestamp_utc as date) as date, sum(amount) as orders, name
from postmates_orders as o
join postmates_markets as m
    on o.city_id=m.id
where cast(order_timestamp_utc as date) in ('2019-03-11', '2019-04-11')
group by cast(order_timestamp_utc as date), name
order by name, date
),

cte2 as (
select *,
lead(orders, 1) over(partition by name order by date asc) as after,
lead(orders, 1) over(partition by name order by date asc) - orders as diff
from cte
),

cte3 as (
select name, diff,
dense_rank() over(order by diff) as rnk
from cte2 
where date = '2019-03-11'
)

select * from cte3
where rnk = (select max(rnk) from cte3) or rnk=(select min(rnk) from cte3)


/* 11. Which partners have ‘pizza’ in their name and are located in Boston? And what is the average order amount? Output the partner name and the average order amount. */
with cte as (
select p.name as partnername, m.name as city, amount
from postmates_orders o
join postmates_markets as m
    on o.city_id = m.id
join postmates_partners p
    on o.seller_id=p.id
where lower(p.name) like '%pizza%' and lower(m.name) = 'boston'
)

select partnername, avg(amount) as avg_amt
from cte
group by partnername

/* 12. Return the top 2 users in each company that called the most. Output the company_id, user_id, and the user's rank. If there are multiple users in the same rank, keep all of them. */
with cte as (
select company_id, c.user_id, count(*) as num_calls
from rc_calls c
join rc_users u
    on c.user_id=u.user_id
group by company_id, c.user_id
),

cte1 as (
select *,
dense_rank() over(partition by company_id order by num_calls desc) as rnk
from cte 
)

select company_id, user_id, rnk
from cte1
where rnk<=2


/* 13. Which company had the biggest month call decline from March to April 2020? Return the company_id and calls difference for the company with the highest decline.*/

with cte as (
select  company_id, 
        extract(year from call_date) as year,
        extract(month from call_date) as month,
        count(*) as mar_calls,
        lead(count(*),1) over(partition by company_id order by extract(year from call_date), extract(month from call_date) asc) as Apr_calls
from rc_calls c
join rc_users u
    on c.user_id=u.user_id
where extract(month from call_date) in (3,4) and
      extract(year from call_date) = 2020 
group by company_id, 
         extract(year from call_date),
         extract(month from call_date)
)

select company_id, apr_calls - mar_calls as call_diff
from cte
where month=3
order by call_diff 
limit 1

/* 14. Redfin helps clients to find agents. Each client will have a unique request_id and each request_id has several calls. For each request_id, the first call is an “initial call” and all the following calls are “update calls”.  What's the average call duration for all initial calls? */
with cte as (
select *,
row_number() over(partition by request_id order by created_on) as rn
from redfin_call_tracking
)
select avg(call_duration) filter(where rn = 1)
from cte

-- OR
with cte as (
select *,
row_number() over(partition by request_id order by created_on) as rn
from redfin_call_tracking
)
select avg(call_duration)
from cte
where rn=1

/* 15. Redfin helps clients to find agents. Each client will have a unique request_id and each request_id has several calls. For each request_id, the first call is an “initial call” and all the following calls are “update calls”.  What's the average call duration for all update calls? */
with cte as (
select *,
row_number() over(partition by request_id order by created_on asc) as rn
from redfin_call_tracking
)
select avg(call_duration) filter(where rn != 1)
from cte

/* 16. Redfin helps clients to find agents. Each client will have a unique request_id and each request_id has several calls. For each request_id, the first call is an “initial call” and all the following calls are “update calls”.  How many customers have called 3 or more times between 3 PM and 6 PM (initial and update calls combined)? */
select count(distinct request_id) as n_cust
from redfin_call_tracking
where datepart(hour, created_on) in (15,16,17)
group by request_id
having count(request_id) >=3
order by count(request_id)

/* 17. Considering a dataset that tracks user interactions with different clients, identify which clients have users who are exclusively loyal to them (i.e., they don't interact with any other clients).
For each of these clients, calculate the number of such exclusive users. The output should include the client_id and the corresponding count of exclusive users.*/
WITH exclusive_pairs AS
  (SELECT user_id,
          MIN(client_id) AS client_id
   FROM fact_events GROUP  BY user_id
   HAVING COUNT(DISTINCT client_id) = 1)
SELECT client_id,
       COUNT(*) AS exclusive_users
FROM exclusive_pairs
GROUP BY client_id
ORDER BY exclusive_users DESC;

/* 18. Write a query that will return all cities with more customers than the average number of  customers of all cities that have at least one customer. For each such city, return the country name,  the city name, and the number of customers */

with cte as (
select city.id, count(*) n_cust
from linkedin_customers as cust
right join linkedin_city as city
    on cust.city_id = city.id
group by city.id
)

select distinct country_name, city_name, n_cust
from linkedin_customers as cust
right join linkedin_city as city
    on cust.city_id = city.id
join linkedin_country as cntry
    on city.country_id=cntry.id
join cte
    on cte.id = city.id
where n_cust > 
    (select avg(n_cust)
    from cte
    where n_cust >1
    )
    
-- OR

    
WITH cities_customers AS (
    SELECT
        country.country_name AS country,
        city.city_name AS city,
        count(customer.id) AS total_customers
    FROM linkedin_country country
    INNER JOIN linkedin_city city
        ON city.country_id = country.id
    INNER JOIN linkedin_customers customer
        ON city.id = customer.city_id
    GROUP BY 
        country.country_name,
        city.city_name   
),

avg_customers AS (
    SELECT count(id) * 1.0 as ct, count(DISTINCT city_id) as den,
        count(id) * 1.0 / count(DISTINCT city_id) AS avg_cus_per_city
    FROM linkedin_customers
)
        
SELECT
    country,
    city,
    total_customers
FROM cities_customers
WHERE
    total_customers > (SELECT avg_cus_per_city FROM avg_customers)

/* 19. Which user flagged the most distinct videos that ended up approved by YouTube? Output, in one column, their full name or names in case of a tie. In the user's full name, include a space between the first and the last name. */
select (user_firstname + ' ' + user_lastname) as name,
        count(distinct video_id) as n_vids,
        rank() over(order by count(distinct video_id) desc) as rnk
from user_flags as f
join flag_review as r
    on f.flag_id=r.flag_id
where lower(reviewed_outcome) = 'approved'
group by user_firstname, user_lastname
)

select name from cte
where rnk = 1

/* 20. Find the most profitable location. Write a query that calculates the average signup duration in days and the average transaction amount for each location. Then, calculate the ratio of average transaction amount to average duration.
Your output should include the location, average signup duration (in days), average transaction amount, and the ratio. Sort the results by ratio in descending order. */
 with days as (
select 
location,
avg(signup_stop_date - signup_start_date) as mean_duration
from signups
group by location
),

revenue as (
select location, avg(amt) as mean_revenue
from transactions t
join signups s
    on s.signup_id=t.signup_id
group by location
),

combined as (
select distinct d.location, mean_duration, mean_revenue
from signups s
    join days d
        on s.location = d.location
    join revenue r
        on s.location = r.location
)

select *, mean_revenue/mean_duration as ratio
from combined
order by ratio desc

/* 21.You are given a table named airbnb_host_searches that contains listings shown to users during Airbnb property searches. Each record represents a property listing (not the user's search query). Determine the minimum, average, and maximum rental prices for each host popularity rating based on the property's number_of_reviews.
The host’s popularity rating is defined as below:
•   0 reviews: "New"
•   1 to 5 reviews: "Rising"
•   6 to 15 reviews: "Trending Up"
•   16 to 40 reviews: "Popular"
•   More than 40 reviews: "Hot"

Tip: The id column in the table refers to the listing ID.
Output host popularity rating and their minimum, average and maximum rental prices. Order the solution by the minimum price. */

select
    (case 
        when number_of_reviews = 0 then 'New'
        when number_of_reviews between 1 and 5 then 'Rising'
        when number_of_reviews between 6 and 15 then 'Trending Up'
        when number_of_reviews between 16 and 40 then 'Popular'
        when number_of_reviews >40 then'Hot' else 'Missing' end) as pop_rating,
        min(price) as min_price,
        avg(price) as avg_price,
        max(price) as max_price
    from airbnb_host_searches
    group by pop_rating
    order by min_price

/* 22. The marketing department wants to identify the top-performing product classes based on the number of orders placed for each class.
If multiple product classes have the same number of sales and qualify for the top 3, include all of them in the output. */

with cte as (
select product_class, count(*) as n_orders,
dense_rank() over(order by count(*) desc) as rn
from online_orders as o 
join online_products as p
    on o.product_id=p.product_id
group by product_class
)

select product_class
from cte
where rn<=3

/* 23. The sales department wants to identify lower-priced products that still sell well.


Find product IDs that meet both of the following criteria:
⦁    The product has been sold at least twice (i.e., appeared in at least two different purchases).
⦁    The unit-weighted average sale price (cost_in_dollars) for that product is at least $3. A unit-weighted average sales price is defined as the total revenue for the product divided by the total number of units sold.
Return a list containing product IDs along with their corresponding brand name. */
select o.product_id, min(p.brand_name)
from online_orders o
join online_products p
    on o.product_id=p.product_id
group by o.product_id
having count(*) >=2 and sum(cast(cost_in_dollars as float)*units_sold) / sum(units_sold)  >3.0


/* 24. Write a query to identify all companies (customer_id) whose mobile usage ranks in the bottom two positions. Mobile usage is the count of events where client_id = 'mobile'. Companies with the same usage count should share the same rank, and all companies in the bottom two ranks should be included. Return the customer_id and event count, sorted in ascending order by the number of events. */
select * from fact_events;
with cte as (
select customer_id, count(*) as event_ct,
       dense_rank() over(order by count(*)) rn
from fact_events
where client_id = 'mobile'
group by customer_id
)
select customer_id, event_ct
from cte
where rn <=2
order by event_ct

