CREATE database coffee_shop_sales_db;
USE coffee_shop_sales_db;
SELECT * FROM coffee_shop_sales_db.`coffee_shop_ sales`;
-- To show all datatype
DESCRIBE `coffee_shop_ sales`;
/* date and time are not in proper data type they are in txt data type so changing*/
UPDATE `coffee_shop_ sales`
SET transaction_date = str_to_date(transaction_date,'%Y-%m-%d');
/* epo str to date convert paniyachu ,next data type change pannaum adhuku alter use */
ALTER TABLE `coffee_shop_ sales`
MODIFY COLUMN transaction_date date;

/*Transcation_time ku change pandrom*/
UPDATE `coffee_shop_ sales`
SET transaction_time = str_to_date(transaction_time,'%H:%i:%s');
/*Alter is used to change datatype of a column*/
ALTER TABLE `coffee_shop_ sales`
MODIFY column transaction_time time;
/*chaning the name of column*/
ALTER TABLE `coffee_shop_ sales`
CHANGE ï»¿transaction_id transaction_id int;
/*still now we have cleaned the raw data*/

/*next step we are queryung for bussiness requirement*/
/*1.Total sale analysis*/
/*total sale for each respective month*/
SELECT ROUND(SUM(transaction_qty*unit_price)) AS total_sales
FROM `coffee_shop_ sales`
WHERE month(transaction_date)=5;  -- may month oodathu varum
/*month on month increase or descrease in sales*/
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    `coffee_shop_ sales`
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
    
/*2.Total order analysis*/
/*total num of order for each res month*/
SELECT COUNT(transcation_id) AS total_orders
FROM `coffee_shop_ sales`
WHERE MONTH(transaction_date)=5;
/*month on month increase or descrease in orders*/
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transcation_id)) AS total_orders,
    (COUNT(transcation_id) - LAG(COUNT(transcation_id), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transcation_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    `coffee_shop_ sales`
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
    
/*3.Total quantity sold analysis*/
/*total quantity each month*/
SELECT SUM(transaction_qty) AS total_quantity
FROM `coffee_shop_ sales`
WHERE MONTH(transaction_date)=5; 
/*month on month increase or descrease in orders*/
SELECT COUNT(transcation_id) AS total_orders
FROM `coffee_shop_ sales`
WHERE MONTH(transaction_date)=5;
/*month on month increase or descrease in quantity*/
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM
    `coffee_shop_ sales`
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
/*Chart requirements*/
/*1.Calendar heat map -adhula total metrics find pandrom like hower pandra apo show aaganum*/
SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1),'K') AS total_sales,
    CONCAT(ROUND(COUNT(transcation_id) / 1000, 1),'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),'K') AS total_quantity_sold
FROM 
    `coffee_shop_ sales`
WHERE 
    transaction_date = '2023-05-18'; -- For 18 May 2023
    
/*2.Sales analysis by weekdays and weekends*/
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
   CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2),'K') AS total_sales
FROM 
    `coffee_shop_ sales`
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY day_type;

/*3.sales by store location*/
SELECT store_location,
CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2),'K') AS total_sales
FROM `coffee_shop_ sales`
WHERE MONTH(transaction_date)=5
group by store_location
order by SUM(unit_price * transaction_qty) DESC;

/*SALES TREND OVER PERIOD*/
SELECT CONCAT(ROUND(AVG(total_sales)/1000,1),'K') AS average_sales
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        `coffee_shop_ sales`
	WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        transaction_date
) AS internal_query;

/*Daily sales for particular month*/
SELECT DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        `coffee_shop_ sales`
	WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        transaction_date
	ORDER BY transaction_date;
    
/*COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”*/
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        `coffee_shop_ sales`
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;

/*SALES BY PRODUCT CATEGORY*/
SELECT 
	product_category,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM `coffee_shop_ sales`
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC;

/*SALES BY PRODUCTS (TOP 10)*/
SELECT 
	product_type,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM `coffee_shop_ sales`
WHERE
	MONTH(transaction_date) = 5  AND product_category='coffee'
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;

/*SALES BY DAY | HOUR*/
SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    `coffee_shop_ sales`
WHERE 
    DAYOFWEEK(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND HOUR(transaction_time) = 8 -- Filter for hour number 8
    AND MONTH(transaction_date) = 5; -- Filter for May (month number 5)
    
/*TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY*/
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    `coffee_shop_ sales`
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;
    
/*TO GET SALES FOR ALL HOURS FOR MONTH OF MAY*/
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    `coffee_shop_ sales`
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);















   
    








