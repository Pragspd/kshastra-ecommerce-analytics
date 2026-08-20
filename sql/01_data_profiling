/*
============================================================
KSHASTRA E-COMMERCE ANALYTICS
01 - DATA PROFILING & DATA QUALITY ASSESSMENT
============================================================

Project:
    Kshastra E-commerce Analytics

Purpose:
    Perform initial data profiling and validation before
    conducting business analysis.

Objectives:
    - Understand the structure and size of each dataset
    - Determine data coverage and granularity
    - Validate unique identifiers
    - Identify duplicate records
    - Examine missing values
    - Profile important business dimensions
    - Validate relationships between datasets
    - Identify data-quality issues that may affect analysis

Tables profiled:
    - website_sessions
    - website_daily
    - orders_clean
    - customers
    - meta_ads_campaigns
    - order_line_items
    - sku_catalog

Database:
    Microsoft SQL Server

============================================================
*/


/* ============================================================
   SECTION 1: WEBSITE SESSIONS
   ============================================================ */


/*
Business Question:
How large is the website session dataset, what dimensions
does it contain, and what period of website activity does it cover?

Purpose:
Establish the basic structure and scope of the session-level
traffic data before calculating traffic and conversion KPIs.
*/

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT session_id) AS unique_sessions,
    COUNT(DISTINCT traffic_source) AS traffic_sources,
    COUNT(DISTINCT campaign_name) AS campaigns,
    COUNT(DISTINCT device_category) AS devices,
    COUNT(DISTINCT city) AS cities,
    MIN(date) AS first_date,
    MAX(date) AS last_date
FROM dbo.website_sessions;


/*
Business Question:
Are session IDs unique?

Purpose:
Identify duplicate session records that could artificially
inflate traffic and funnel metrics.
*/

SELECT
    session_id,
    COUNT(*) AS occurrence_count
FROM dbo.website_sessions
GROUP BY session_id
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;


/*
Business Question:
How many duplicate session rows exist in total?

Purpose:
Quantify the scale of the duplication issue identified above.
*/

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT session_id) AS unique_sessions,
    COUNT(*) - COUNT(DISTINCT session_id) AS duplicate_rows
FROM dbo.website_sessions;


/*
Business Question:
Is campaign attribution available consistently across
traffic sources?

Purpose:
Assess whether campaign-level analysis can be performed
consistently across all acquisition channels.
*/

SELECT
    traffic_source,
    COUNT(*) AS sessions,
    SUM(
        CASE
            WHEN campaign_name IS NULL THEN 1
            ELSE 0
        END
    ) AS null_campaign_sessions,
    CAST(
        100.0 *
        SUM(CASE WHEN campaign_name IS NULL THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS null_campaign_pct
FROM dbo.website_sessions
GROUP BY traffic_source
ORDER BY sessions DESC;


/*
Business Question:
Does purchase behavior differ across device categories?

Purpose:
Establish an initial view of device-level purchase performance
for later conversion analysis.
*/

SELECT
    device_category,
    SUM(sessions) AS sessions,
    SUM(purchased) AS purchases,
    CAST(
        100.0 * SUM(purchased)
        / NULLIF(SUM(sessions), 0)
        AS DECIMAL(10,2)
    ) AS purchase_rate_pct
FROM dbo.website_sessions
GROUP BY device_category
ORDER BY purchase_rate_pct DESC;


/* ============================================================
   SECTION 2: WEBSITE DAILY
   ============================================================ */


/*
Business Question:
What is the overall scale and time coverage of the daily
website performance dataset?

Purpose:
Understand the available daily traffic, engagement,
checkout, purchase and revenue measures.
*/

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT date) AS unique_dates,
    MIN(date) AS first_date,
    MAX(date) AS last_date,
    SUM(sessions) AS total_sessions,
    SUM(product_views) AS total_product_views,
    SUM(add_to_cart) AS total_add_to_cart,
    SUM(begin_checkout) AS total_checkouts,
    SUM(purchases) AS total_purchases,
    SUM(revenue) AS total_revenue
FROM dbo.website_daily;


/*
Business Question:
How are purchases distributed between purchased and
non-purchased sessions?

Purpose:
Understand the distribution of the purchased indicator
before calculating conversion metrics.
*/

SELECT
    purchased,
    COUNT(*) AS rows
FROM dbo.website_daily
GROUP BY purchased
ORDER BY purchased;


/*
Business Question:
How do website purchases and revenue vary by year?

Purpose:
Establish a high-level temporal baseline for later trend
and growth analysis.
*/

SELECT
    YEAR(date) AS year,
    SUM(purchases) AS yearly_purchases,
    SUM(revenue) AS yearly_revenue
FROM dbo.website_daily
GROUP BY YEAR(date)
ORDER BY year;


/* ============================================================
   SECTION 3: ORDERS CLEAN
   ============================================================ */


/*
Business Question:
Is the cleaned order dataset unique at the order level,
and what period of order activity does it cover?

Purpose:
Validate order-level grain before using the table for
revenue, customer and order analysis.
*/

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Order_ID) AS unique_orders,
    COUNT(*) - COUNT(DISTINCT Order_ID) AS duplicate_rows,
    COUNT(DISTINCT Customer_ID) AS unique_customers,
    MIN(Order_date_time) AS first_order,
    MAX(Order_date_time) AS last_order
FROM dbo.orders_clean;


/*
Business Question:
Are there duplicate Order IDs?

Purpose:
Confirm that each order is represented once in the cleaned
order dataset.
*/

SELECT
    Order_ID,
    COUNT(*) AS occurrence_count
FROM dbo.orders_clean
GROUP BY Order_ID
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;


/*
Business Question:
How do order values behave across the gross, net and
combined source fields?

Purpose:
Validate monetary fields before using them in revenue KPIs.
*/

SELECT TOP 20
    Order_ID,
    Order_value_gross_net,
    Order_value_gross,
    Order_value_net
FROM dbo.orders_clean
WHERE Order_value_gross_net IS NOT NULL;


/*
Data Quality Finding:
Order_value_gross_net was found to contain the gross and
net order values concatenated together.

Example:
23391814 = 2339 + 1814

Analytical Decision:
Order_value_gross_net is excluded from monetary calculations.
Order_value_gross and Order_value_net are used instead.
*/


/* ============================================================
   SECTION 4: CUSTOMERS
   ============================================================ */


/*
Business Question:
How many customers are represented in the customer dataset,
and how does customer order frequency vary?

Purpose:
Establish the customer base and understand repeat purchasing
behavior.
*/

SELECT
    Total_orders,
    COUNT(*) AS customers
FROM dbo.customers
GROUP BY Total_orders
ORDER BY Total_orders;


/*
Business Question:
What proportion of customers are repeat purchasers?

Purpose:
Establish a baseline customer retention metric.
*/

SELECT
    RePurchased,
    COUNT(*) AS customers,
    CAST(
        100.0 * COUNT(*)
        / SUM(COUNT(*)) OVER ()
        AS DECIMAL(10,2)
    ) AS customer_pct
FROM dbo.customers
GROUP BY RePurchased
ORDER BY RePurchased;


/*
Business Question:
Does repeat purchasing vary by first-touch acquisition channel?

Purpose:
Identify whether certain acquisition channels appear to
produce stronger repeat-customer behavior.
*/

SELECT
    Acquisition_channel_first_touch,
    COUNT(*) AS customers,
    SUM(
        CASE
            WHEN RePurchased = 'Y' THEN 1
            ELSE 0
        END
    ) AS repeat_customers,
    CAST(
        100.0 *
        SUM(CASE WHEN RePurchased = 'Y' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS repeat_rate_pct
FROM dbo.customers
GROUP BY Acquisition_channel_first_touch
ORDER BY repeat_rate_pct DESC;


/* ============================================================
   SECTION 5: META ADS CAMPAIGNS
   ============================================================ */


/*
Business Question:
What is the overall scope of the Meta advertising dataset?

Purpose:
Understand campaign, ad-set, date and spend coverage before
evaluating advertising performance.
*/

SELECT
    COUNT(DISTINCT campaign_name) AS campaigns,
    COUNT(DISTINCT adset_name) AS adsets,
    MIN(date) AS first_date,
    MAX(date) AS last_date,
    SUM(spend) AS total_spend,
    SUM(purchases) AS total_purchases,
    SUM(purchase_conversion_value) AS total_conversion_value
FROM dbo.meta_ads_campaigns;


/*
Business Question:
Are duplicate advertising records present?

Purpose:
Check whether campaign metrics could be double-counted.
*/

SELECT
    campaign_name,
    adset_name,
    date,
    COUNT(*) AS row_count
FROM dbo.meta_ads_campaigns
GROUP BY
    campaign_name,
    adset_name,
    date
HAVING COUNT(*) > 1;


/*
Business Question:
Do Amount_spent_INR and spend contain the same values?

Purpose:
Identify redundant fields and establish which field should
be used consistently in later analysis.
*/

SELECT
    SUM(CASE WHEN Amount_spent_INR = spend THEN 1 ELSE 0 END)
        AS same_spend_rows,
    SUM(CASE WHEN Amount_spent_INR <> spend THEN 1 ELSE 0 END)
        AS different_spend_rows
FROM dbo.meta_ads_campaigns;


/*
Business Question:
Do Results and link_clicks contain the same values?

Purpose:
Identify redundant advertising metrics and avoid double
counting the same performance measure under different names.
*/

SELECT
    SUM(CASE WHEN Results = link_clicks THEN 1 ELSE 0 END)
        AS same_result_click_rows,
    SUM(CASE WHEN Results <> link_clicks THEN 1 ELSE 0 END)
        AS different_result_click_rows
FROM dbo.meta_ads_campaigns;


/*
Business Question:
What is the overall Meta advertising funnel?

Purpose:
Establish the total progression from clicks through
add-to-cart, checkout and purchase.
*/

SELECT
    SUM(link_clicks) AS total_clicks,
    SUM(add_to_cart) AS total_add_to_cart,
    SUM(initiate_checkout) AS total_checkouts,
    SUM(purchases) AS total_purchases
FROM dbo.meta_ads_campaigns;


/* ============================================================
   SECTION 6: ORDER LINE ITEMS
   ============================================================ */


/*
Business Question:
What is the size and product-level granularity of the
order line-item dataset?

Purpose:
Understand the number of line items, orders, SKUs,
categories and returned items available for product analysis.
*/

SELECT
    COUNT(*) AS total_line_items,
    COUNT(DISTINCT Order_ID) AS unique_orders,
    COUNT(DISTINCT SKU_ID) AS unique_skus,
    COUNT(DISTINCT Category_top_bottom_outer) AS categories,
    COUNT(DISTINCT Size) AS sizes,
    COUNT(DISTINCT Color) AS colors,
    SUM(
        CASE
            WHEN Returned_Y_N = 'Y' THEN 1
            ELSE 0
        END
    ) AS returned_items
FROM dbo.order_line_items;


/*
Business Question:
How do product categories differ in sales, discounting
and returns?

Purpose:
Establish a baseline view of category performance.
*/

SELECT
    Category_top_bottom_outer AS category,
    COUNT(*) AS line_items,
    SUM(Selling_price) AS sales_value,
    AVG(Selling_price) AS avg_selling_price,
    AVG(Discount) AS avg_discount_pct,
    SUM(
        CASE
            WHEN Returned_Y_N = 'Y' THEN 1
            ELSE 0
        END
    ) AS returned_items
FROM dbo.order_line_items
GROUP BY Category_top_bottom_outer
ORDER BY sales_value DESC;


/*
Business Question:
What are the main reasons for product returns?

Purpose:
Identify the leading product and operational issues
associated with returned items.
*/

SELECT
    Return_reason_if_any,
    COUNT(*) AS returned_items
FROM dbo.order_line_items
WHERE Returned_Y_N = 'Y'
GROUP BY Return_reason_if_any
ORDER BY returned_items DESC;


/* ============================================================
   SECTION 7: SKU CATALOG
   ============================================================ */


/*
Business Question:
What is the size and product coverage of the SKU catalog?

Purpose:
Understand SKU, category and vendor coverage and the range
of pricing and product costs.
*/

SELECT
    COUNT(*) AS total_skus,
    COUNT(DISTINCT SKU) AS unique_skus,
    COUNT(DISTINCT Category) AS categories,
    COUNT(DISTINCT Vendor) AS vendors,
    MIN(MRP) AS min_mrp,
    MAX(MRP) AS max_mrp,
    MIN(Cost_per_unit) AS min_cost,
    MAX(Cost_per_unit) AS max_cost
FROM dbo.sku_catalog;


/*
Business Question:
How does unit-level margin potential vary by category?

Purpose:
Compare average pricing and product cost to establish
baseline product economics.
*/

SELECT
    Category,
    COUNT(*) AS skus,
    AVG(MRP) AS avg_mrp,
    AVG(Cost_per_unit) AS avg_cost,
    AVG(MRP - Cost_per_unit) AS avg_gross_margin_per_unit
FROM dbo.sku_catalog
GROUP BY Category
ORDER BY avg_gross_margin_per_unit DESC;


/* ============================================================
   END OF DATA PROFILING
   ============================================================

   Key profiling outcomes:

   1. Website sessions contain duplicate session records.
   2. Campaign attribution is not consistently populated
      across traffic sources.
   3. orders_clean contains 30,000 unique orders.
   4. Order_value_gross_net is a concatenated gross/net field
      and is excluded from monetary analysis.
   5. Meta advertising contains redundant spend/click fields.
   6. Customer data supports repeat-purchase analysis.
   7. Product data supports discount and return analysis.
   8. SKU catalog data supports product-cost and margin analysis.

   Next Phase:
   Business-focused EDA covering traffic, conversion,
   marketing efficiency, customers, products, discounts
   and returns.
============================================================
*/
