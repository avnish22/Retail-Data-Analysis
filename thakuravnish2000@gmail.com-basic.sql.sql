----------------------------CASE STUDY - 1(RETAIL DATA ANALYSIS)--------------------------------------------------


CREATE DATABASE RETAIL_STORE;

USE RETAIL_STORE;

SELECT TOP 1 * FROM Customer

SELECT TOP 1 * FROM prod_cat_info

SELECT TOP 1 * FROM Transactions


------------------------------DATA PREPERATION AND UNDERSTANDING-------------------------------------

--1. What is the total number of rows in each of the 3 tables in the database?

SELECT COUNT(*) AS Row_count, 'Customer' AS Table_name FROM Customer
UNION ALL
SELECT COUNT(*) AS Row_count, 'prod_cat_info' AS Table_name FROM prod_cat_info
UNION ALL
SELECT COUNT(*) AS Row_count, 'Transactions' AS Table_name FROM Transactions


--2. What is the total number of transactions that have a return?

SELECT COUNT(transaction_id) AS total_transaction
FROM Transactions
WHERE total_amt < 0;


--3. As you would have noticed, the dates provided across the datasets are not in a correct 
--format. As first steps, pls convert the date variables into valid date formats before 
--proceeding ahead.

SELECT CONVERT(DATE, A.DOB, 101) AS CorrectDateFormat_Table1, CONVERT(DATE, B.tran_date, 101) AS CorrectDateFormat_Table2
FROM 
    Customer AS A
INNER JOIN Transactions AS B
ON A.customer_Id = B.cust_id;


--4. What is the time range of the transaction data available for analysis? 
--Show the output in number of days, months and years simultaneously in different columns.

SELECT *,
DAY(tran_date) AS DAY_,
MONTH(tran_date) AS MONTH_,
YEAR(tran_date) AS YEAR_
FROM Transactions;


--5. Which product category does the sub-category “DIY” belong to?

SELECT prod_subcat, prod_cat FROM prod_cat_info
WHERE prod_subcat = 'DIY';



-----------------------------------DATA ANALYSIS-----------------------------------------------

--1. Which channel is most frequently used for transactions?

SELECT TOP 1 Store_type AS Channel,
COUNT(Store_type) AS Cnt_of_Store_type 
FROM Transactions
group by Store_type
ORDER BY Cnt_of_Store_type DESC;


--2. What is the count of Male and Female customers in the database?

SELECT Gender, COUNT(Gender) AS Count_gender
FROM Customer
GROUP BY Gender
HAVING Gender IS NOT NULL;


--3. From which city do we have the maximum number of customers and how many?

SELECT TOP 1 city_code AS City, 
COUNT(*) AS Tot_Count
FROM Customer
group by city_code
ORDER BY COUNT(*) DESC;


--4. How many sub-categories are there under the Books category?

SELECT COUNT(prod_subcat) AS CNT_SUB_CAT
FROM prod_cat_info
WHERE prod_cat = 'Books';

-------OR--------------

SELECT 
prod_cat, COUNT(prod_subcat) AS cnt_sub_cat
FROM prod_cat_info
GROUP BY prod_cat
Having prod_cat = 'Books';


--5. What is the maximum quantity of products ever ordered?

SELECT TOP 1 prod_cat_code, COUNT(Qty) AS cnt_of_quantity
FROM Transactions
GROUP BY prod_cat_code
ORDER BY cnt_of_quantity DESC;


--6. What is the net total revenue generated in categories Electronics and Books?

SELECT A.prod_cat AS categories, SUM(B.total_amt) AS Revenue FROM prod_cat_info AS A
INNER JOIN Transactions AS B
ON a.prod_cat_code = b.prod_cat_code AND A.prod_sub_cat_code = B.prod_subcat_code
WHERE A.prod_cat = 'ELECTRONICS' OR A.prod_cat = 'BOOKS'
GROUP BY A.prod_cat


--7. How many customers have > 10 transactions with us, excluding returns?

SELECT COUNT(A.customer_Id) AS CNT_Customer ,A.customer_Id FROM Customer AS A
INNER JOIN Transactions AS B
ON A.customer_Id = B.cust_id
WHERE B.total_amt > 0
GROUP BY A.customer_Id
HAVING COUNT(A.customer_Id) > 10;


--8. What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?

SELECT A.prod_cat AS categories, SUM(total_amt) AS Tot_Revenue
FROM prod_cat_info AS A
INNER JOIN Transactions AS B
ON A.prod_cat_code = B.prod_cat_code AND A.prod_sub_cat_code = B.prod_subcat_code
WHERE A.prod_cat IN ('Electronics','Clothing') AND B.Store_type = 'Flagship store'
GROUP BY A.prod_cat



--9. What is the total revenue generated from “Male” customers in “Electronics” category?
--Output should display total revenue by prod sub-cat.

SELECT C.prod_subcat, SUM(B.total_amt) AS Tot_revenue
FROM Customer AS A
INNER JOIN Transactions AS B 
ON A.customer_Id = B.cust_id
INNER JOIN prod_cat_info AS C
ON C.prod_cat_code = B.prod_cat_code AND C.prod_sub_cat_code = B.prod_subcat_code
WHERE A.Gender = 'M' AND C.prod_cat = 'Electronics'
GROUP BY C.prod_subcat;



--10. What is percentage of sales and returns by product sub category; 
--display only top 5 sub categories in terms of sales?

WITH SalesReturns AS (
    SELECT A.prod_subcat_code, prod_subcat, SUM(CASE WHEN total_amt > 0 THEN total_amt ELSE 0 END) AS total_sales,
    SUM(CASE WHEN total_amt < 0 THEN total_amt ELSE 0 END) AS total_returns
    FROM Transactions AS A
    JOIN prod_cat_info AS B 
	ON A.prod_cat_code = B.prod_cat_code AND A.prod_subcat_code = B.prod_sub_cat_code
    GROUP BY A.prod_subcat_code, prod_subcat
)
SELECT TOP 5 prod_subcat_code, prod_subcat, total_sales, total_returns,
(total_sales / NULLIF((total_sales - total_returns), 0)) * 100 AS sales_percentage
FROM SalesReturns
ORDER BY total_sales DESC;



--11.	For all customers aged between 25 to 35 years find what is the net total revenue generated by 
--these consumers in last 30 days of transactions from max transaction date available in the data?

SELECT  ROUND ( SUM(total_amt),3) AS Net_Total_Revenue 
FROM   Transactions AS A
INNER JOIN  Customer AS B
ON A.cust_id = B.customer_Id
WHERE tran_date BETWEEN DATEADD(DAY, -30, (SELECT MAX(tran_date) FROM Transactions)) 
AND (SELECT MAX(tran_date) FROM Transactions) AND YEAR(GETDATE()) - YEAR(DOB) BETWEEN 25 AND 35


--12.	Which product category has seen the max value of returns in the last 3 months of transactions?

SELECT TOP 1 B.prod_cat AS product_category, SUM(A.total_amt) AS total_returns
FROM Transactions AS A
INNER JOIN prod_cat_info AS B 
ON A.prod_cat_code = B.prod_cat_code
WHERE A.tran_date >= DATEADD(month, -3, '2014-02-28') AND A.tran_date <= '2014-02-28' AND A.total_amt < 0 
GROUP BY  B.prod_cat
ORDER BY total_returns DESC


--13.	Which store-type sells the maximum products; by value of sales amount and by quantity sold?

SELECT Store_type, SUM(total_amt) AS total_sales_amount, SUM(Qty) AS total_quantity_sold
FROM Transactions
GROUP BY Store_type
ORDER BY total_sales_amount DESC, total_quantity_sold DESC


--14.	What are the categories for which average revenue is above the overall average.

SELECT A.prod_cat
FROM prod_cat_info AS A
INNER JOIN Transactions AS B ON A.prod_cat_code = B.prod_cat_code
GROUP BY A.prod_cat
HAVING AVG(B.total_amt) > (SELECT AVG(total_amt) FROM Transactions);


--15.	Find the average and total revenue by each subcategory for the categories
--which are among top 5 categories in terms of quantity sold.

SELECT A.prod_subcat_code, B.prod_subcat, AVG(A.total_amt) AS avg_revenue_per_subcategory,
SUM(A.total_amt) AS total_revenue_per_subcategory
FROM Transactions AS A
INNER JOIN prod_cat_info AS B
ON A.prod_cat_code = B.prod_cat_code AND A.prod_subcat_code = B.prod_sub_cat_code
INNER JOIN (
    SELECT TOP 5 prod_cat_code, SUM(Qty) AS total_quantity_sold
    FROM Transactions
    GROUP BY prod_cat_code
    ORDER BY total_quantity_sold DESC
    ) AS T
	ON A.prod_cat_code = T.prod_cat_code
    GROUP BY A.prod_subcat_code, B.prod_subcat
    ORDER BY avg_revenue_per_subcategory DESC;



