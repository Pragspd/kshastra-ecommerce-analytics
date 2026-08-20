/*
============================================================
KSHASTRA E-COMMERCE ANALYTICS
02 - TRAFFIC & CONVERSION ANALYSIS
============================================================

Business Objective:
    Understand how website traffic progresses through the
    purchase journey and identify potential conversion gaps.

Key Questions:
    1. How much traffic reaches the website?
    2. How many users engage with products?
    3. How many add products to cart?
    4. How many begin checkout?
    5. How many ultimately purchase?
    6. What is the overall purchase conversion rate?

============================================================
*/


/*
------------------------------------------------------------
1. OVERALL WEBSITE FUNNEL

Business Question:
What does the overall website purchase funnel look like?

Purpose:
Establish the baseline funnel before comparing channels,
devices and cities.
------------------------------------------------------------
*/

SELECT
    SUM(sessions) AS total_sessions,
    SUM(product_views) AS total_product_views,
    SUM(add_to_cart) AS total_add_to_cart,
    SUM(begin_checkout) AS total_checkouts,
    SUM(purchases) AS total_purchases,
    SUM(revenue) AS total_revenue,

    CAST(
        100.0 * SUM(purchases)
        / NULLIF(SUM(sessions), 0)
        AS DECIMAL(10,2)
    ) AS purchase_conversion_rate_pct

FROM dbo.website_daily;

/*
Finding:
The dataset contains 475,658 sessions and 30,000 purchases,
resulting in an overall purchase conversion rate of 6.31%.

Data Quality Observation:
Recorded purchases (30,000) exceed begin_checkout events (8,877).
Therefore, the website_daily engagement metrics should not
currently be treated as a strictly sequential funnel.

Analytical Decision:
Purchase conversion from sessions will be used as a baseline KPI.
Stage-to-stage funnel conversion will be validated separately
before being used in the dashboard.
*/

/*
------------------------------------------------------------
2. TRAFFIC SOURCE PERFORMANCE

Business Question:
Which acquisition channels generate the most traffic and
purchases, and how efficiently does each channel convert?

Metrics:
    - Sessions
    - Purchases
    - Purchase conversion rate
    - Revenue

Business Use:
Helps identify channels that generate high traffic versus
channels that generate higher-quality traffic.
------------------------------------------------------------
*/

SELECT
    traffic_source,
    SUM(sessions) AS total_sessions,
    SUM(purchases) AS total_purchases,
    SUM(revenue) AS total_revenue,

    CAST(
        100.0 * SUM(purchases)
        / NULLIF(SUM(sessions), 0)
        AS DECIMAL(10,2)
    ) AS purchase_conversion_rate_pct

FROM dbo.website_daily

GROUP BY traffic_source

ORDER BY purchase_conversion_rate_pct DESC;
/*
Finding:
Organic Instagram has the highest observed purchase
conversion rate at 13.75%, substantially above the other
traffic sources.

Meta generates the largest traffic volume with 228,192
sessions, representing approximately 48% of total sessions,
but its purchase conversion rate is 5.67%.

Business Interpretation:
Meta appears to be the primary scale/traffic channel, while
Organic Instagram appears to generate more conversion-efficient
traffic.

Analytical Implication:
Marketing channels should not be evaluated using traffic
volume alone. Traffic quality and conversion efficiency should
also be considered when evaluating channel performance.

Next Analysis:
Investigate whether channel performance varies by city,
device category, customer segment and campaign.
*/

/*
------------------------------------------------------------
3. CITY-LEVEL PERFORMANCE

Business Question:
Which cities generate the most traffic and which cities
convert that traffic most effectively?

Business Use:
Identify geographic markets with strong demand as well as
potential opportunities for conversion improvement.

This analysis can later support city-specific marketing
or promotional strategies.
------------------------------------------------------------
*/

SELECT
    city,
    SUM(sessions) AS total_sessions,
    SUM(purchases) AS total_purchases,
    SUM(revenue) AS total_revenue,

    CAST(
        100.0 * SUM(purchases)
        / NULLIF(SUM(sessions), 0)
        AS DECIMAL(10,2)
    ) AS purchase_conversion_rate_pct

FROM dbo.website_daily

GROUP BY city

ORDER BY total_sessions DESC;

/*
Finding:
City-level purchase conversion is relatively consistent
across the observed markets, ranging from approximately
6.12% to 6.50%.

Mumbai records the highest conversion rate at 6.50%, while
Jaipur records the lowest at 6.12%.

Business Interpretation:
Geography alone does not appear to be a major differentiator
of purchase conversion in the current dataset.

Analytical Implication:
City-specific discounting should not be recommended based
solely on overall conversion rates. Further segmentation
by device, traffic source, customer behavior, discounts and
returns is required before making geographic pricing or
promotion recommendations.
*/
/*
------------------------------------------------------------
4. DEVICE-LEVEL PERFORMANCE

Business Question:
Does purchase conversion differ across mobile, desktop
and tablet users?

Business Use:
Identify whether a particular device category may represent
a conversion optimization opportunity.

------------------------------------------------------------
*/

SELECT
    device_category,
    SUM(sessions) AS total_sessions,
    SUM(purchases) AS total_purchases,
    SUM(revenue) AS total_revenue,

    CAST(
        100.0 * SUM(purchases)
        / NULLIF(SUM(sessions), 0)
        AS DECIMAL(10,2)
    ) AS purchase_conversion_rate_pct

FROM dbo.website_daily

GROUP BY device_category

ORDER BY purchase_conversion_rate_pct DESC;
/*
Finding:
Mobile accounts for the majority of website sessions and
purchases, with 333,250 sessions and 21,179 purchases.

Despite the large difference in traffic volume, purchase
conversion rates are relatively consistent across devices:

    Tablet   - 6.40%
    Mobile   - 6.36%
    Desktop  - 6.15%

Business Interpretation:
Device category does not appear to be a major differentiator
of purchase conversion in the overall dataset.

Mobile should nevertheless receive high UX priority because
it represents the largest traffic and purchase volume.

Analytical Implication:
Rather than applying device-specific discounts, further
analysis should investigate whether particular traffic
sources perform differently across devices.
*/

/*
------------------------------------------------------------
5. TRAFFIC SOURCE × DEVICE PERFORMANCE

Business Question:
Does acquisition-channel performance vary by device?

Business Use:
Identify channel/device combinations with relatively strong
or weak conversion performance.

This can help prioritize channel-specific UX optimization
and campaign targeting.
------------------------------------------------------------
*/

SELECT
    traffic_source,
    device_category,
    SUM(sessions) AS total_sessions,
    SUM(purchases) AS total_purchases,
    SUM(revenue) AS total_revenue,

    CAST(
        100.0 * SUM(purchases)
        / NULLIF(SUM(sessions), 0)
        AS DECIMAL(10,2)
    ) AS purchase_conversion_rate_pct

FROM dbo.website_daily

GROUP BY
    traffic_source,
    device_category

ORDER BY
    traffic_source,
    purchase_conversion_rate_pct DESC;


/*
Finding:
Traffic-source performance remains materially different
across device categories.

Organic Instagram records substantially higher purchase
conversion across mobile, desktop and tablet, rather than
being concentrated in a single device category.

Meta generates the largest volume of sessions and purchases,
particularly on mobile, but conversion remains around 5.6%-5.7%
across devices.

Business Interpretation:
Organic Instagram appears to generate highly conversion-efficient
traffic, while Meta operates primarily as a high-scale acquisition
channel.

Analytical Implication:
Channel evaluation should combine traffic volume, conversion
efficiency and advertising economics rather than relying on
sessions alone.

Next Analysis:
Evaluate marketing spend, CAC and ROAS at campaign level.
*/

