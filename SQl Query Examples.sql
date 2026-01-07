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

select count(*) as num_events, event_name
from playbook_events
where device = lower('macbook pro')
group by event_name
order by num_events desc
