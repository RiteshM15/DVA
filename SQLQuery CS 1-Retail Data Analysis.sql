CREATE DATABASE SQL_CS_1; 

Use SQL_CS_1;

----------------------------------------DATA PREPARATION AND UNDERSTANDING------------------------
Select * from Customer;
Select * from Transactionsfile;
Select * from prod_cat_info;

--Q1.What is the total number of rows in each of the 3 tables in database?.
select Count(*) as Total_rows_C 
from Customer;

select Count(*) as Total_rows_TF 
from Transactionsfile;

select count(*) as Total_rows_PCI
from prod_cat_info;

--Q2 What is the total no of transactions that have a return?
select count(*)as total_return_Rows from Transactionsfile
where total_amt<1;

/*Q3 As you would have notice, the dates provided  across the datasets are not in the correct formate.As first steps, 
please convert the dates variables in to valid date formates before proceeding ahead*/

SELECT CONVERT(date,tran_date,105)as new_tran_date  from Transactionsfile;
SELECT CONVERT(date,DOB,105)as NEW_DOB_DATES  from Customer;
--Q4.BEGIN
SELECT *
FROM Transactionsfile
WHERE tran_date >= '2011-01-25' AND tran_date < '2014-02-28';
--
SELECT
tran_date, 
CONVERT(date,tran_date,105)as new_tran_date,
YEAR(tran_date) as trans_year,
MONTH(tran_date) as trans_month,
DAY(tran_date) as Trans_day
from Transactionsfile;

SELECT DATEDIFF(DAY, MIN(CONVERT(DATE, tran_date, 105)), MAX(CONVERT(DATE, tran_date, 105))), 
DATEDIFF(MONTH, MIN(CONVERT(DATE, tran_date, 105)), MAX(CONVERT(DATE, tran_date, 105))),  
DATEDIFF(YEAR, MIN(CONVERT(DATE, tran_date, 105)), MAX(CONVERT(DATE,tran_date, 105))) 
FROM Transactionsfile;
--Q4. End

--Q5 BEGINS
Select prod_cat from prod_cat_info
where prod_subcat='DIY';
--Q5 ENDS

------------------------------------------------DATA ANALYSIS----------------------------------------------------------------


--1. Which channel is most frequently used for transactions? 

SELECT Top 1 store_type,
COUNT(*) AS Most_transaction_channel
FROM Transactionsfile
GROUP BY store_type
ORDER BY Most_transaction_channel desc;

--2. What is the count of Male and Female customers in the database?
SELECT Gender,
count(*) as Gender_count
from Customer
where Gender IN('M','F')
Group by Gender;

--3. From which city do we have the maximum number of customers and how many?
Select top 1  city_code,
count (city_code) as Max_no_Cust
from Customer
group by city_code
order by Max_no_Cust Desc;

--4.How many sub-categories are there under the Books category?
select prod_cat,
count(*) AS Prod_subcat_count
from prod_cat_info
where prod_cat='books'
group by prod_cat;

--5. What is the maximum quantity of products ever ordered?
Select top 1 prod_cat_code,
count(prod_cat_code) as Max_quatity_products
from Transactionsfile
group by prod_cat_code
order by  Max_quatity_products desc;

SELECT MAX(Qty) as Max_quantity
from Transactionsfile;


--6. What is the net total revenue generated in categories Electronics and Books?
Select  SUM(total_amt) as Revenue 
FROM Transactionsfile AS TF 
Inner Join prod_cat_info  as PCI 
ON TF.prod_cat_code=PCI.prod_cat_code
and prod_subcat_code = prod_sub_cat_code
WHERE prod_cat IN ('BOOKS' , 'ELECTRONICS');


--7. How many customers have >10 transactions with us, excluding returns?
Select COUNT(customer_Id) AS CUSTOMER_COUNT
FROM Customer WHERE customer_Id IN 
(
Select cust_id
FROM Transactionsfile
LEFT JOIN Customer 
ON customer_Id = cust_id
Where total_amt NOT like '-%'
Group by
cust_id
Having 
count(transaction_id) > 10
);

--8. What is the combined revenue earned from the "Electronics" & "Clothing" categories, from "Flagship stores"?
Select  SUM(total_amt) as Revenue 
FROM Transactionsfile as TF 
INNER JOIN
prod_cat_info as PCI 
ON TF.prod_cat_code = PCI.prod_cat_code
AND prod_sub_cat_code=prod_subcat_code
WHERE PCI.prod_cat = 'electronics' or PCI.prod_cat = 'clothing' and TF.Store_type = 'Flagship stores';

--9. What is the total revenue generated from "Male" customers in "Electronics" category? Output should display total revenue by prod sub-cat. 
SELECT SUM(total_amt) as Total_Revenue,
prod_subcat FROM Transactionsfile as TF 
LEFT JOIN prod_cat_info  AS PCI
ON TF.prod_cat_code = PCI.prod_cat_code  LEFT JOIN Customer AS C 
ON C.customer_Id = TF.cust_id 
WHERE PCI.prod_cat_code = '3' and C.Gender = 'M' 
GROUP BY PCI.prod_subcat,TF.prod_subcat_code;

--10. What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?
SELECT TOP 5 prod_subcat,
(Sum(total_amt)/(SELECT Sum(total_amt) FROM Transactionsfile))*100 AS Percentage_of_sales, 
(Count(CASE WHEN Qty < 0 THEN Qty ELSE NULL END)/count(Qty))*100 AS Percentage_of_return
FROM Transactionsfile as TF
INNER JOIN prod_cat_info as PCI
ON TF.prod_cat_code = PCI.prod_cat_code AND TF.prod_subcat_code=PCI.prod_sub_cat_code
GROUP BY   prod_subcat
ORDER BY Sum(total_amt) DESC;

--11. For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 30 days of transactions from max transaction date available in the data?
SELECT Cust_id ,SUM(total_amt) AS	TOTAL_REVENUE 
FROM Transactionsfile
WHERE cust_id IN 
	(SELECT customer_Id
	 FROM Customer
     WHERE DATEDIFF(YEAR,CONVERT(DATE,DOB,103),GETDATE()) BETWEEN 25 AND 35)
     AND CONVERT(DATE,tran_date,103) BETWEEN DATEADD(DAY,-30,(SELECT MAX(CONVERT(DATE,tran_date,103))
	 FROM Transactionsfile)) 
	 AND (SELECT MAX(CONVERT(DATE,tran_date,103)) 
	 FROM Transactionsfile)
GROUP BY CUST_ID;

--12. Which product category has seen the max value of returns in the last 3 months of transactions?
SELECT TOP 1 prod_cat, sum(total_amt) as Max_value_return FROM Transactionsfile as TF
INNER JOIN prod_cat_info as PCI ON TF.prod_cat_code = PCI.prod_cat_code 
AND TF.prod_subcat_code = PCI.prod_sub_cat_code
WHERE total_amt< 1 AND 
CONVERT(date, tran_date, 103) BETWEEN DATEADD(MONTH,-3,(SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactionsfile)) 
	 AND (SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactionsfile)
GROUP BY prod_cat;

--13. Which store-type sells the maximum products; by value of sales amount and by quantity sold?

SELECT  Store_type, SUM(total_amt) as Total_Sales, count(QTY) as Total_Qty
FROM Transactionsfile
GROUP BY Store_type
HAVING SUM(total_amt) >=ALL (SELECT SUM(total_amt) FROM Transactionsfile GROUP BY Store_type)
AND count(QTY) >=ALL (SELECT count(Qty) FROM Transactionsfile GROUP BY Store_type);

--14. What are the categories for which average revenue is above the overall average.
SELECT prod_cat, AVG(total_amt) AS Average
FROM Transactionsfile as TF
INNER JOIN prod_cat_info as PCI 
ON  TF.prod_cat_code=PCI.prod_cat_code AND prod_sub_cat_code=prod_subcat_code
GROUP BY prod_cat
HAVING AVG(total_amt)> (SELECT AVG(total_amt) FROM Transactionsfile);

--15. Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.
SELECT prod_cat,prod_subcat,AVG(total_amt) AS AVERAGE_REV,SUM(total_amt) AS TOTAL_REVENUE
FROM Transactionsfile as TF
INNER JOIN prod_cat_info as PCI 
ON TF.prod_cat_code=PCI.prod_cat_code AND prod_sub_cat_code=prod_subcat_code
WHERE prod_cat IN
(
SELECT TOP 5 
prod_cat
FROM Transactionsfile as TF 
INNER JOIN prod_cat_info as PCI 
ON TF.prod_cat_code=PCI.prod_cat_code AND prod_sub_cat_code = prod_subcat_code
GROUP BY PROD_CAT
ORDER BY count(Qty) DESC
)
GROUP BY prod_cat,prod_subcat;


 




