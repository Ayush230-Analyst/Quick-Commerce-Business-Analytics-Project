USE quick_commerce_analysis;
SELECT DATABASE();
-- 1. DATA VALIDATION -- 
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM order_payments;
SELECT COUNT(*) FROM order_reviews;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM sellers;
SELECT COUNT(*) FROM geolocation;
SELECT COUNT(*) FROM category_translation; 
-- 1.1 Check Duplicates --
SELECT COUNT(*) - COUNT(DISTINCT customer_id) AS duplicate_customers
FROM customers;
SELECT COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_orders
FROM orders;
SELECT COUNT(*) - COUNT(DISTINCT product_id) AS duplicate_products
FROM products; 
-- 1.2 Check Missing Values --
SELECT COUNT(*) AS missing_category
FROM products
WHERE product_category_name IS NULL
OR product_category_name = '';  
SELECT COUNT(*)
FROM order_reviews
WHERE review_score IS NULL;
SELECT COUNT(*)
FROM order_payments
WHERE payment_value IS NULL;
SELECT COUNT(*)
FROM customers
WHERE customer_state IS NULL
OR customer_state='';
-- 2: MASTER TABLE CREATION --
DROP TABLE IF EXISTS ecommerce_master;
CREATE TABLE ecommerce_master AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    p.product_category_name,
    op.payment_type,
    op.payment_value,
    r.review_score,
    c.customer_city,
    c.customer_state
FROM orders o
LEFT JOIN customers c
       ON o.customer_id = c.customer_id
LEFT JOIN order_items oi
       ON o.order_id = oi.order_id
LEFT JOIN order_payments op
       ON o.order_id = op.order_id
LEFT JOIN order_reviews r
       ON o.order_id = r.order_id
LEFT JOIN products p
       ON oi.product_id = p.product_id; 
SELECT COUNT(*) FROM ecommerce_master;
-- 3: KPI ANALYSIS -- 
-- 3.1 Total Revenue --
SELECT ROUND(SUM(payment_value),2) AS Total_Revenue
FROM ecommerce_master;  
-- 3.2 Total Orders --
SELECT COUNT(DISTINCT order_id) AS Total_Orders
FROM ecommerce_master;
-- 3.3 Total Customers --
SELECT COUNT(DISTINCT customer_id) AS Total_Customers
FROM ecommerce_master;  
-- 3.4 Average Order Value --
SELECT ROUND(
SUM(payment_value) /
COUNT(DISTINCT order_id),2
) AS Average_Order_Value
FROM ecommerce_master;  
-- 3.5 Average Review Score --
SELECT ROUND(AVG(review_score),2) AS Avg_Review_Score
FROM ecommerce_master;
-- 4. CUSTOMER ANALYSIS -- 
-- 4.1 Top States by Customers --
SELECT
customer_state,
COUNT(DISTINCT customer_id) AS Total_Customers
FROM ecommerce_master
GROUP BY customer_state
ORDER BY Total_Customers DESC;  
-- 4.2 Top Cities by Customers --
SELECT
customer_city,
COUNT(DISTINCT customer_id) AS Total_Customers
FROM ecommerce_master
GROUP BY customer_city
ORDER BY Total_Customers DESC
LIMIT 10;
-- 5 PRODUCT ANALYSIS --
-- 5.1 Top Product Categories --
SELECT
product_category_name,
COUNT(*) AS Total_Sales
FROM ecommerce_master
GROUP BY product_category_name
ORDER BY Total_Sales DESC
LIMIT 10;   
-- 5.2 Highest Revenue Categories --
SELECT
product_category_name,
ROUND(SUM(payment_value),2) AS Revenue
FROM ecommerce_master
GROUP BY product_category_name
ORDER BY Revenue DESC
LIMIT 10;  
-- 6. SELLER ANALYSIS --  
-- 6.1 Top Sellers --
SELECT
seller_id,
ROUND(SUM(payment_value),2) AS Revenue
FROM ecommerce_master
GROUP BY seller_id
ORDER BY Revenue DESC
LIMIT 10;   
-- 6.2 Seller Count --
SELECT COUNT(DISTINCT seller_id)
AS Total_Sellers
FROM ecommerce_master;  
-- 7. PAYMENT ANALYSIS --
-- 7.1 Most Used Payment Types --
SELECT
payment_type,
COUNT(*) AS Usage_Count
FROM ecommerce_master
GROUP BY payment_type
ORDER BY Usage_Count DESC;   
-- 7.2 Revenue by Payment Type --
SELECT
payment_type,
ROUND(SUM(payment_value),2) AS Revenue
FROM ecommerce_master
GROUP BY payment_type
ORDER BY Revenue DESC;  
-- 8. REVIEW ANALYSIS --
-- 8.1 Review Distribution --
SELECT
review_score,
COUNT(*) AS Reviews
FROM ecommerce_master
GROUP BY review_score
ORDER BY review_score;   
-- 8.2 Review vs Revenue --
SELECT
review_score,
ROUND(AVG(payment_value),2) AS Avg_Revenue
FROM ecommerce_master
GROUP BY review_score
ORDER BY review_score;  
-- 9. BUSINESS INSIGHTS --
-- 9.1 Top 10 States by Revenue --
SELECT
customer_state,
ROUND(SUM(payment_value),2) AS Revenue
FROM ecommerce_master
GROUP BY customer_state
ORDER BY Revenue DESC
LIMIT 10;   
-- 9.2 Top 10 Cities by Revenue --
SELECT
customer_city,
ROUND(SUM(payment_value),2) AS Revenue
FROM ecommerce_master
GROUP BY customer_city
ORDER BY Revenue DESC
LIMIT 10; 
SELECT COUNT(*) FROM ecommerce_master;
-- 9.3 Revenue by Product Category -- 
SELECT
product_category_name,
ROUND(SUM(payment_value),2) AS Revenue
FROM ecommerce_master
GROUP BY product_category_name
ORDER BY Revenue DESC
LIMIT 10;
-- 9.4 Top 10 Customers by Spending -- 
SELECT
customer_id,
ROUND(SUM(payment_value),2) AS Total_Spending
FROM ecommerce_master
GROUP BY customer_id
ORDER BY Total_Spending DESC
LIMIT 10;
-- 9.5 Revenue by State --
SELECT
customer_state,
ROUND(SUM(payment_value),2) AS Revenue
FROM ecommerce_master
GROUP BY customer_state
ORDER BY Revenue DESC;  
-- 9.6 Category-wise Customer Satisfaction --
SELECT
product_category_name,
ROUND(AVG(review_score),2) AS Avg_Review_Score
FROM ecommerce_master
GROUP BY product_category_name
ORDER BY Avg_Review_Score DESC;  

-- BUSINESS INSIGHTS & RECOMMENDATIONS
-- Insight 1:
-- Total Revenue generated = 20.58 Million.

-- Insight 2:
-- Sao Paulo (SP) is the largest customer and revenue contributing state.

-- Insight 3:
-- Sao Paulo city is the most valuable market.

-- Insight 4:
-- Bed, Bath & Table category generates the highest revenue.

-- Insight 5:
-- Credit Card is the most preferred payment method.

-- Insight 6:
-- Average customer review score is 4.02, indicating high satisfaction.

-- Insight 7:
-- Revenue is concentrated among a small number of top sellers.

-- Recommendation 1:
-- Increase marketing investment in SP, RJ and MG.

-- Recommendation 2:
-- Expand inventory in high-performing categories.

-- Recommendation 3:
-- Improve experience for high-value customers.

-- Recommendation 4:
-- Support mid-tier sellers to diversify revenue sources.

-- Recommendation 5:
-- Continue optimizing credit card payment experience.
  
  

