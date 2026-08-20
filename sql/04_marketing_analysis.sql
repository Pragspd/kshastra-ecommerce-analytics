/*
============================================================
KSHASTRA E-COMMERCE ANALYTICS
03 - MARKETING PERFORMANCE ANALYSIS
============================================================

Business Objective:
    Evaluate the efficiency of paid advertising by comparing
    advertising spend with clicks, purchases and attributed
    conversion value.

Key Questions:
    1. How much is being spent on advertising?
    2. How many users are reached and engaged?
    3. How many purchases are generated?
    4. How much conversion value is attributed to advertising?
    5. What is the overall advertising ROAS?

============================================================
*/


/*
------------------------------------------------------------
1. OVERALL PAID MARKETING PERFORMANCE

Business Question:
What is the overall performance of the paid advertising
dataset?

Metrics:
    - Spend
    - Impressions
    - Link clicks
    - Add to cart
    - Checkout
    - Purchases
    - Conversion value
    - ROAS

Business Use:
Establish a baseline for evaluating paid marketing efficiency.
------------------------------------------------------------
*/

SELECT
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(link_clicks) AS total_link_clicks,
    SUM(add_to_cart) AS total_add_to_cart,
    SUM(initiate_checkout) AS total_checkouts,
    SUM(purchases) AS total_purchases,
    SUM(purchase_conversion_value) AS total_conversion_value,

    CAST(
        100.0 * SUM(link_clicks)
        / NULLIF(SUM(impressions), 0)
        AS DECIMAL(10,2)
    ) AS ctr_pct,

    CAST(
        SUM(purchase_conversion_value)
        / NULLIF(SUM(spend), 0)
        AS DECIMAL(10,2)
    ) AS overall_roas

FROM dbo.meta_ads_campaigns;

/*
------------------------------------------------------------
2. CAMPAIGN-LEVEL PERFORMANCE

Business Question:
Which advertising campaigns generate the strongest
commercial results?

Business Use:
Compare campaigns using spend, purchases, conversion value
and ROAS rather than judging campaigns by clicks alone.
------------------------------------------------------------
*/

SELECT
    campaign_name,

    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(link_clicks) AS total_clicks,
    SUM(purchases) AS total_purchases,
    SUM(purchase_conversion_value) AS conversion_value,

    CAST(
        100.0 * SUM(link_clicks)
        / NULLIF(SUM(impressions), 0)
        AS DECIMAL(10,2)
    ) AS ctr_pct,

    CAST(
        SUM(spend)
        / NULLIF(SUM(purchases), 0)
        AS DECIMAL(10,2)
    ) AS cost_per_purchase,

    CAST(
        SUM(purchase_conversion_value)
        / NULLIF(SUM(spend), 0)
        AS DECIMAL(10,2)
    ) AS roas

FROM dbo.meta_ads_campaigns

GROUP BY campaign_name

ORDER BY roas DESC;

/*
Finding:
The Meta advertising dataset records ₹6.83M in total spend
and ₹16.74M in attributed purchase conversion value,
resulting in an overall ROAS of 2.45x.

The campaigns generated 316,689 link clicks and 6,654 purchases,
with an overall CTR of 0.85%.

The resulting advertising cost per attributed purchase is
approximately ₹1,026.

Business Interpretation:
Paid advertising generates more attributed conversion value
than advertising spend at the aggregate level.

However, ROAS should not be interpreted as profit because
product costs, returns, RTO, shipping and other operating costs
are not included in this calculation.

Analytical Implication:
Campaign-level performance should be analyzed next to identify
high-performing and underperforming campaigns rather than
evaluating Meta advertising using the aggregate ROAS alone.
*/

SELECT
    campaign_name,
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(link_clicks) AS total_clicks,
    SUM(purchases) AS total_purchases,
    SUM(purchase_conversion_value) AS conversion_value,

    CAST(
        100.0 * SUM(link_clicks)
        / NULLIF(SUM(impressions), 0)
        AS DECIMAL(10,2)
    ) AS ctr_pct,

    CAST(
        SUM(spend)
        / NULLIF(SUM(purchases), 0)
        AS DECIMAL(10,2)
    ) AS cost_per_purchase,

    CAST(
        SUM(purchase_conversion_value)
        / NULLIF(SUM(spend), 0)
        AS DECIMAL(10,2)
    ) AS roas

FROM dbo.meta_ads_campaigns

GROUP BY campaign_name

ORDER BY roas DESC;

/*
Finding:
Campaign-level advertising performance varies substantially
across the Meta campaign portfolio.

Several March 2023 campaigns demonstrate very high ROAS,
with KS_Mar23_Camp_06 recording 13.33x ROAS and a cost per
purchase of approximately ₹206.

Other campaigns in the dataset show materially lower ROAS
despite generating significant impressions and clicks.

Business Interpretation:
Aggregate Meta ROAS of 2.45x masks substantial variation
between individual campaigns.

Analytical Implication:
Campaign performance should be evaluated using a combination
of ROAS, cost per purchase, purchase volume and spend.
High-ROAS campaigns should not automatically be scaled without
considering their current spending level and purchase volume.

Next Analysis:
Investigate campaign/ad-set and creative-level characteristics
to understand what drives stronger advertising performance.
*/

/*
------------------------------------------------------------
3. CREATIVE TYPE PERFORMANCE

Business Question:
Which advertising creative formats generate stronger
commercial performance?

Business Use:
Identify creative formats associated with stronger
engagement and advertising efficiency.
------------------------------------------------------------
*/

SELECT
    creative_type,

    COUNT(DISTINCT campaign_name) AS campaigns,

    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(link_clicks) AS total_clicks,
    SUM(purchases) AS total_purchases,
    SUM(purchase_conversion_value) AS conversion_value,

    CAST(
        100.0 * SUM(link_clicks)
        / NULLIF(SUM(impressions), 0)
        AS DECIMAL(10,2)
    ) AS ctr_pct,

    CAST(
        SUM(spend)
        / NULLIF(SUM(purchases), 0)
        AS DECIMAL(10,2)
    ) AS cost_per_purchase,

    CAST(
        SUM(purchase_conversion_value)
        / NULLIF(SUM(spend), 0)
        AS DECIMAL(10,2)
    ) AS roas

FROM dbo.meta_ads_campaigns

GROUP BY creative_type

ORDER BY roas DESC;
/*
Finding:
Creative formats show substantial variation in advertising
efficiency.

Studio-Reel has the highest observed ROAS at 5.87x and the
lowest cost per purchase at approximately ₹406.

Static creative records 3.18x ROAS, followed by Carousel
at 2.41x, UGC-Reel at 2.12x and UGC-Story at 1.89x.

Business Interpretation:
Studio-Reel campaigns appear to be the most efficient
creative format in the observed dataset.

However, Studio-Reel is represented by only four campaigns,
compared with 17 UGC-Reel and 11 UGC-Story campaigns.
Therefore, creative type alone cannot establish causation.

Analytical Implication:
Creative performance should be evaluated alongside campaign
timing, spend, audience/ad-set characteristics and campaign
scale before making creative investment recommendations.
*/
/*
------------------------------------------------------------
4. AD-SET PERFORMANCE

Business Question:
Which ad sets generate the strongest advertising efficiency?

Business Use:
Identify high-performing audience/ad-set segments and
underperforming segments for further investigation.
------------------------------------------------------------
*/

SELECT
    adset_name,

    COUNT(DISTINCT campaign_name) AS campaigns,

    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(link_clicks) AS total_clicks,
    SUM(purchases) AS total_purchases,
    SUM(purchase_conversion_value) AS conversion_value,

    CAST(
        100.0 * SUM(link_clicks)
        / NULLIF(SUM(impressions), 0)
        AS DECIMAL(10,2)
    ) AS ctr_pct,

    CAST(
        SUM(spend)
        / NULLIF(SUM(purchases), 0)
        AS DECIMAL(10,2)
    ) AS cost_per_purchase,

    CAST(
        SUM(purchase_conversion_value)
        / NULLIF(SUM(spend), 0)
        AS DECIMAL(10,2)
    ) AS roas

FROM dbo.meta_ads_campaigns

GROUP BY adset_name

ORDER BY roas DESC;
/*
Finding:
Ad-set performance varies substantially across the Meta
advertising portfolio.

Interest_Streetwear records the strongest combination of
scale and efficiency, generating 1,362 purchases at a
3.80x ROAS and approximately ₹672 cost per purchase.

Retarget_7D also performs strongly at 3.74x ROAS and
approximately ₹649 cost per purchase.

Lookalike_1% receives the highest spend at approximately
₹1.71M but records the lowest ROAS at 1.81x and the highest
cost per purchase at approximately ₹1,348.

Business Interpretation:
Interest-based and short-window retargeting audiences show
stronger observed advertising efficiency than the other
ad-set groups.

Lookalike_1% represents a potential optimization area because
it combines high spend with relatively weak observed return.

Analytical Implication:
Budget allocation should be evaluated using both efficiency
and scale. High-spend, low-efficiency ad sets should be
investigated before additional budget is allocated.

Next Analysis:
Evaluate campaign performance by time period and identify
whether advertising efficiency changes over time.
*/
/*
------------------------------------------------------------
5. MONTHLY ADVERTISING PERFORMANCE

Business Question:
How does paid advertising efficiency change over time?

Business Use:
Identify periods of improving or deteriorating advertising
efficiency and determine whether spend is scaling alongside
performance.
------------------------------------------------------------
*/

SELECT
    YEAR(date) AS year,
    MONTH(date) AS month,

    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(link_clicks) AS total_clicks,
    SUM(purchases) AS total_purchases,
    SUM(purchase_conversion_value) AS conversion_value,

    CAST(
        100.0 * SUM(link_clicks)
        / NULLIF(SUM(impressions), 0)
        AS DECIMAL(10,2)
    ) AS ctr_pct,

    CAST(
        SUM(spend)
        / NULLIF(SUM(purchases), 0)
        AS DECIMAL(10,2)
    ) AS cost_per_purchase,

    CAST(
        SUM(purchase_conversion_value)
        / NULLIF(SUM(spend), 0)
        AS DECIMAL(10,2)
    ) AS roas

FROM dbo.meta_ads_campaigns

GROUP BY
    YEAR(date),
    MONTH(date)

ORDER BY
    year,
    month;
    /*
Finding:
Paid advertising performance varies substantially over time.

For example, March 2023 records 11.34x ROAS and approximately
₹214 cost per purchase, while May 2023 falls to 0.97x ROAS
with approximately ₹2,892 cost per purchase.

March 2024 records a further decline to 0.65x ROAS and
approximately ₹3,598 cost per purchase.

Business Interpretation:
Aggregate advertising ROAS of 2.45x masks significant
period-to-period variation in advertising efficiency.

This indicates that campaign performance should be evaluated
over time rather than using only a portfolio-level average.

Data Quality Note:
The Meta advertising dataset does not contain records for every
calendar month. Missing months should not be interpreted as
zero advertising activity without additional validation.

Analytical Implication:
Periods of unusually strong and weak performance should be
investigated to identify potential changes in campaigns,
creative formats, audiences, spend levels or other factors.
*/
