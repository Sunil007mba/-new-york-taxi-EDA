select * from NewYorkTaxi2..nyc_taxi_trip

--Checking Seperatly Date and Time from Pickup_datetime 

Select pickup_datetime from NewYorkTaxi2..nyc_taxi_trip

select cast(pickup_datetime AS date),cast(pickup_datetime AS Time) 
from NewYorkTaxi2..nyc_taxi_trip


--Count the null values in columns 

Select COUNT(*) as [Total Number of Rows] from NewYorkTaxi2..nyc_taxi_trip

Select SUM(CASE WHEN vendor_id IS NULL  THEN 1 ELSE 0 END) 
AS [Number Of Null Values]
    ,COUNT(vendor_id) AS [Number Of Non-Null Values] 
    FROM NewYorkTaxi2..nyc_taxi_trip   


--calculate some aggregate values of trip duration

SELECT DISTINCT [passenger_count]
  , ROUND (sum ([trip_duration]),0) as Totaltripduration
  , ROUND (avg ([trip_duration]),0) as Avgtripduration
FROM NewYorkTaxi2..nyc_taxi_trip
where passenger_count!=0
GROUP BY [passenger_count]
order by [passenger_count] desc



--find out and Remove duplicate values if any using CTE

with Removeduplicate (vendor_id,trip_duration, passenger_count,RNK)
as
(
select vendor_id,trip_duration, passenger_count,ROW_NUMBER() over(partition by 
vendor_id,pickup_datetime,dropoff_datetime,trip_duration, passenger_count
order by passenger_count desc) 
from NewYorkTaxi2..nyc_taxi_trip
)
select * from Removeduplicate


--Exploring and updating the pickup and dropoff datetime   

select pickup_datetime,day(pickup_datetime) as pickup_in_day,MONTH(pickup_datetime) as pickup_in_month,
datepart(hour,[pickup_datetime]) as pickup_in_hours,DATEPART(dw,pickup_datetime) as pickup_weekname,
datepart(MINUTE,[pickup_datetime]) as pickup_in_min
from NewYorkTaxi2..nyc_taxi_trip


alter table NewYorkTaxi2..nyc_taxi_trip
add pickup_date date, pickup_Time Time

update NewYorkTaxi2..nyc_taxi_trip
set pickup_date= convert(date,pickup_datetime)

update NewYorkTaxi2..nyc_taxi_trip
set [pickup_Time]= convert(time(0),pickup_datetime)

update NewYorkTaxi2..nyc_taxi_trip
set [pickup_Time]= convert(time(0),pickup_Time)

update NewYorkTaxi2..nyc_taxi_trip
set pickup_Time=LEFT(CONVERT(VARCHAR,pickup_Time,108),5)


alter table NewYorkTaxi2..nyc_taxi_trip
ADD dropoff_date date, dropoff_time time
 

update NewYorkTaxi2..nyc_taxi_trip
set [dropoff_date]= convert(date,dropoff_datetime)

update NewYorkTaxi2..nyc_taxi_trip
set [dropoff_time]= convert(time(0),dropoff_datetime)


--Explore max number passenger according order in ride

select max(passenger_count) as maximun_no_passenger
from NewYorkTaxi2..nyc_taxi_trip
where passenger_count!=0
group by passenger_count
order by passenger_count desc


--Explore by day of week
with day_of_week as (
select passenger_count,trip_duration,DATEPART(dw from pickup_datetime) as dow 
from NewYorkTaxi2..nyc_taxi_trip
)
select passenger_count,
CASE when dow = 0 then 'Sunday'
     when dow = 1 then 'Monday'
     when dow = 2 then 'Tuesday'
     When dow = 3 then 'Wednesday'
     when dow = 4 then 'Thursday'
     when dow =5 then 'Friday'
     when dow =6 then 'Saturday'
     else 'others'
     end as day_of_week, count(dow) as count_of_weekdays
     from day_of_week
	 group by passenger_count,dow
	 order by COUNT(dow) desc 
 
--count of passenger more than equal to 5 min trip_duration

select distinct(sum(passenger_count)) as num_of_passenger,trip_duration,passenger_count
from NewYorkTaxi2..nyc_taxi_trip
where trip_duration>= 300
group by passenger_count,trip_duration
order by trip_duration

select * from NewYorkTaxi2..nyc_taxi_trip

--Explore accordingly timming by Ranging in a day
select *, case when 
				CAST(pickup_Time as time) between '5:00:00.001' and '12:00:00.000' then 'Morning' 
				when CAST(pickup_Time as time) between '12:00:00.001' and '17:00:00.000' then 'Afternoon' 
				when CAST(pickup_time as time) between '17:00:00.001' and '22:00:00.000' then 'Evening' 
				else 'Night'
				end  as pickup_time_in_a_day
				from NewYorkTaxi2..nyc_taxi_trip


--Counting of trips how many are stored or fwd with vendor
select store_and_fwd_flag, count(store_and_fwd_flag)as count_stored_value
from NewYorkTaxi2..nyc_taxi_trip
group by store_and_fwd_flag

