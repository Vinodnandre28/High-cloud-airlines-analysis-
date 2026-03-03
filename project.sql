Use airline;

show tables;
select * from maindata;
select count(*) from maindata;
select count(*) from flight_types;
desc maindata;


ALTER TABLE maindata 
RENAME COLUMN `%Distance Group ID` TO Distance_Group_ID;

ALTER TABLE maindata CHANGE `# Available Seats` `Available_seats` INT;
ALTER TABLE maindata CHANGE COLUMN `%Airline ID` Airline_ID INT;
ALTER TABLE maindata CHANGE COLUMN `%Carrier Group ID` carrier_group_ID INT;

desc maindata;
ALTER TABLE maindata 
RENAME COLUMN `From - To City` TO From_To_city;
ALTER TABLE maindata 
RENAME COLUMN `Carrier Name` TO Carrier_Name;
ALTER TABLE maindata 
RENAME COLUMN `# Transported Passengers` TO Transported_passengers;


Create view order_date as
select
concat(Year, '-', Month, '-', day) as order_date,
Transporetd_passengers,
Available_seats,
From_to_city,
Carrier_name,
Distance_group_Id
from 
maindata;

Select * from order_date limit 10;


# Q1 calcuate the following fields from the Year	Month (#)	Day  fields ( First Create a Date Field from Year , Month , Day fields)
#  A.Year
#  B.Monthno
#  C.Monthfullname
#  D.Quarter(Q1,Q2,Q3,Q4)
#  E. YearMonth ( YYYY-MMM)
#  F. Weekdayno
#  G.Weekdayname
#  H.FinancialMOnth;


create view KPI1 as select year(order_date) as year_number,
month(order_date) as month_number,
day(order_date) as day_number,
monthname(order_date) as month_name,
concat("Q",quarter(order_date) as quarter_number,
concat(year(order_date),'_',monthname(order_date)) as year_month_number,
weekday(order_date) as weekday_number,
dayname(order_date) as day_name,
case
when quarter(order_date)=1 then"FQ4"
when quarter(order_date)=2 then"FQ1"
when quarter(order_date)=3 then"FQ2"
when quarter(order_date)=4 then"FQ3"
end as finacial_quarter,
case 
when month(order_date)= 1 then "10"
when month(order_date)= 2 then "11"
when month(order_date)= 3 then "12"
when month(order_date)= 4 then "1"
when month(order_date)= 5 then "2"
when month(order_date)= 6 then "3"
when month(order_date)= 7 then "4"
when month(order_date)= 8 then "5"
when month(order_date)= 9 then "6"
when month(order_date)= 10 then "7"
when month(order_date)= 11 then "8"
when month(order_date)= 12 then "9"
end as Financial_month,
case
when weekday(order_date) in (5,6) then "weekend"
when weekday(order_date) in  (0,1,2,3,4) then "weekday"
end as weekend_weekday,
transported_passengers,
available_seats,
from_to_city,
carrier_name,
Distance_group_ID
from order_date;






desc Maindata;

# 1.calcuate the following fields from the Year	Month (#)	Day  fields ( First Create a Date Field from Year , Month , Day fields)
A.Year
B.Monthno
C.Monthfullname
D.Quarter(Q1,Q2,Q3,Q4)
E. YearMonth ( YYYY-MMM)
F. Weekdayno
G.Weekdayname
H.FinancialMOnth
I. Financial Quarter 
 

SELECT 
Year,
`Month (#)` AS Monthno,
MONTHNAME(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d')) AS Monthfullname,
CONCAT('Q', QUARTER(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d'))) AS Quarter,
DATE_FORMAT(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d'), '%Y-%M') AS YearMonth,
WEEKDAY(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d')) + 1 AS Weekdayno,
DAYNAME(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d')) AS Weekdayname,
-- Financial Month (Assuming April start: April=1, March=12)
CASE WHEN `Month (#)` >= 4 THEN `Month (#)` - 3 ELSE `Month (#)` + 9 END AS FinancialMonth,
-- Financial Quarter
CASE 
WHEN `Month (#)` BETWEEN 4 AND 6 THEN 'FQ1'
WHEN `Month (#)` BETWEEN 7 AND 9 THEN 'FQ2'
WHEN `Month (#)` BETWEEN 10 AND 12 THEN 'FQ3'
ELSE 'FQ4' 
END AS FinancialQuarter
FROM maindata;





desc maindata;
# 2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)
SELECT 
Year, 
`Month (#)` AS Month,
CONCAT('Q', QUARTER(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-01'), '%Y-%m-%d'))) AS Quarter,
(SUM(`Transported_passengers`) / NULLIF(SUM(`Available_seats`), 0)) * 100 AS Load_Factor_Percentage
FROM maindata
GROUP BY Year, Quarter, Month;


desc maindata;
# 3. Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)
SELECT 
`Carrier_Name`,
(SUM(`Transported_passengers`) / NULLIF(SUM(`Available_seats`), 0)) * 100 AS Load_Factor_Percentage
FROM maindata
GROUP BY `Carrier_Name`;


#4. Identify Top 10 Carrier Names based passengers preference 
SELECT 
`Carrier_Name`, 
SUM(`Transported_Passengers`) AS Total_Passengers
FROM maindata
GROUP BY `Carrier_Name`
ORDER BY Total_Passengers DESC
LIMIT 10;


desc maindata;

# 5. Display top Routes ( from-to City) based on Number of Flights 
SELECT 
`From_To_city`, 
COUNT(*) AS Number_of_Flights
FROM maindata
GROUP BY `From_To_city`
ORDER BY Number_of_Flights DESC;


# 6. Identify the how much load factor is occupied on Weekend vs Weekdays.
desc maindata;
SELECT 
CASE 
WHEN DAYNAME(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d')) IN ('Saturday', 'Sunday') 
THEN 'Weekend' 
ELSE 'Weekday' 
END AS Day_Type,
(SUM(`Transported_passengers`) / NULLIF(SUM(`Available_seats`), 0)) * 100 AS Load_Factor_Percentage
FROM maindata
GROUP BY Day_Type;

desc maindata;
# 7. Use the filter to provide a search capability to find the flights between Source Country, Source State, Source City to Destination Country , Destination State, Destination City 
SELECT * FROM maindata
WHERE `Origin Country` = 'United States' 
AND `Origin State` = 'California' 
AND `Origin City` = 'San Francisco, CA'
AND `Destination Country` = 'United States' 
AND `Destination State` = 'New York' 
AND `Destination City` = 'New York, NY';
  
  
desc maindata;
# 8 Identify number of flights based on Distance groups
SELECT 
`Distance_Group_ID` AS Distance_Group, 
COUNT(*) AS Number_of_Flights
FROM maindata
GROUP BY `Distance_Group_ID`
ORDER BY Distance_Group;










