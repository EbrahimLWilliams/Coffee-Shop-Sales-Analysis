--REVIEW OF DATA FILE/ RAW DATA
--Checked available data/ columns for analysis
SELECT
  *
FROM BRIGHTCO.TRANSACTIONS.COFFEESHOP
--transaction_id, transaction_date, store_id, store_location, product_id, unit_price, product_category, product_type, product_detail

LIMIT
  10;

  --Checked Number of Records

SELECT COUNT (*)
FROM BRIGHTCO.TRANSACTIONS.COFFEESHOP;

SELECT COUNT (DISTINCT transaction_id)
FROM BRIGHTCO.TRANSACTIONS.COFFEESHOP;

--149116 Records

--Checked for duplicates 

SELECT *, COUNT (*)
FROM 
BRIGHTCO.TRANSACTIONS.COFFEESHOP
GROUP BY ALL
HAVING COUNT (8) >1;
--No Results/ Duplicates

--Conversion /Updating of entries

UPDATE BRIGHTCO.TRANSACTIONS.COFFEESHOP
SET transaction_date = REPLACE (transaction_date, '/', '-');

UPDATE BRIGHTCO.TRANSACTIONS.COFFEESHOP
SET unit_price = REPLACE (unit_price, ',', '.');
--Entries updated.

SELECT 
SUM (transaction_qty) AS number_of_units_sold, 
product_category, 
FROM BRIGHTCO.TRANSACTIONS.COFFEESHOP
GROUP BY product_category;

--Flags
--Time Flags
SELECT
MIN (transaction_time)
FROM BRIGHTCO.TRANSACTIONS.COFFEESHOP;
--06:00:00

SELECT
MAX (transaction_time)
FROM BRIGHTCO.TRANSACTIONS.COFFEESHOP;
--20:59:32

--Product Sales Flag
SELECT transaction_id,
SUM (transaction_qty) AS number_of_units, 
FROM BRIGHTCO.TRANSACTIONS. COFFEESHOP
GROUP BY transaction_id
ORDER BY number_of_units DESC;
--Highest - 8
--Lowest -1


--FINAL QUERY FOR ANALYSIS

SELECT
SUM (transaction_qty*unit_price) AS total_revenue,
SUM (transaction_qty) AS number_of_units_sold, 
COUNT (product_id) AS unique_products_sold,
COUNT (DISTINCT transaction_id) AS number_of_sales,

product_category,
product_type, 
product_detail, 
store_location,

TO_DATE (transaction_date) AS purchase_date,
TO_CHAR (transaction_date, 'YYYYMM') AS month_id,
MONTHNAME (transaction_date) AS month_name,
DAYNAME (transaction_date) AS day_name,

CASE 
WHEN transaction_time BETWEEN '04:00:00' AND '09:59:00' THEN 'Morning Rush (Peak)'
WHEN transaction_time BETWEEN '10:00:00' AND '11:59:00' THEN 'Mid-Morning (Off-Peak)'
WHEN transaction_time BETWEEN '12:00:00' AND '13:59:59' THEN 'Lunchtime (Peak)'
WHEN transaction_time BETWEEN '14:00:00' AND '14:59:59' THEN 'Mid-Afternoon (Off-Peak)'
WHEN transaction_time BETWEEN '15:00:00' AND '16:59:59' THEN 'Afternoon Slump (Peak)'
ELSE 'Evenings (Off-Peak)'
END AS time_bucket, 

CASE 
WHEN SUM (transaction_qty*unit_price) BETWEEN 0 AND 20 THEN 'Low Spenders'
WHEN SUM (transaction_qty*unit_price) BETWEEN 21 AND 40 THEN 'Medium Spenders'
WHEN SUM (transaction_qty*unit_price) BETWEEN 41 AND 60 THEN 'High Spenders'
ELSE 'Very High Spenders'
END AS spending_bands,

CASE 
WHEN SUM (transaction_qty) BETWEEN 0 AND 2 THEN 'Low Performing'
WHEN SUM (transaction_qty) BETWEEN 3 AND 4 THEN 'Medium Performing'
WHEN SUM (transaction_qty) BETWEEN 5 AND 7 THEN 'High High Performing'
ELSE 'Very High Performing'
END AS product_performance,

FROM BRIGHTCO.TRANSACTIONS.COFFEESHOP
GROUP BY time_bucket, 
         product_category,
         product_type,
         product_detail, 
         store_location,
         purchase_date,
         month_id, 
         month_name, 
         day_name;
