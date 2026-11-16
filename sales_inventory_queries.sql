-- Executive KPI summary (Total Sales, Profit, Total Quantity Sold and Profit Margin)
SELECT
ROUND(SUM(sales),2) AS total_sales,
ROUND(SUM(profit),2) AS total_profit,
SUM(quantity) AS total_units_sold,
ROUND((SUM(profit) / NULLIF(SUM(sales),0)) * 100,2) AS profit_margin_pct
FROM superstore;

-- Sales, Profit and Inventory Volume by Region
SELECT
region,
ROUND(SUM(sales),2) AS total_sales,
ROUND(SUM(profit),2) AS total_profit,
SUM(quantity) as toal_quantity_sold
FROM superstore
GROUP BY region
ORDER BY total_sales DESC;

-- Top Selling Categories by Revenue.
SELECT
category,
SUM(quantity) AS unit_sold,
ROUND(SUM(sales),0) AS total_revenue
FROM superstore
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 5;

-- Inventory Velocity & Profitability by Sub-Category (Identifying High-Volume / Low-Profit Stock)
SELECT
category,
sub_category,
SUM(quantity) AS total_units_sold,
ROUND(SUM(sales),0) AS total_sales,
ROUND(SUM(profit),0) AS total_profit
FROM superstore
GROUP BY category, sub_category
ORDER BY total_units_sold DESC;


-- Monthly Sales Trend & Month-over-Month (MoM) Growth %
WITH monthly_sales AS (
SELECT 
DATE_TRUNC('month', order_date)::DATE AS sales_month,
ROUND(SUM(sales), 2) AS current_month_sales
FROM supeRSTORE
GROUP BY 1
)
SELECT 
sales_month,
current_month_sales,
LAG(current_month_sales) OVER (ORDER BY sales_month) AS prev_month_sales,
ROUND(
((current_month_sales - LAG(current_month_sales) OVER (ORDER BY sales_month)) 
/ NULLIF(LAG(current_month_sales) OVER (ORDER BY sales_month), 0)) * 100, 2
) AS mom_growth_pct
FROM monthly_sales
ORDER BY sales_month;

--Loss-Making Sub-Categories (Discount Impact Analysis)
SELECT
sub_category,
ROUND(AVG(discount) * 100,2) AS avg_discount_pct,
ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit DESC;


CREATE OR REPLACE VIEW vw_sales_inventory AS
SELECT 
    *,
    (ship_date - order_date) AS shipping_days,
    ROUND((profit / NULLIF(sales, 0)) * 100, 2) AS row_profit_margin_pct
FROM superstore

SELECT
    order_id,
    order_date,
    ship_date,
    (ship_date - order_date) AS shipping_days
FROM superstore
WHERE ship_date < order_date
ORDER BY order_date;

