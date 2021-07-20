-- trafic conv rates
SELECT COUNT(w.website_session_id) AS sessions, COUNT(o.order_id) AS orders, COUNT(o.order_id)/COUNT(w.website_session_id) AS session_to_order_conv_rate
FROM website_sessions AS w
LEFT JOIN orders AS o
ON w.website_session_id = o.website_session_id
WHERE w.created_at < '2012-04-14' AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand';
-- conclusion: 


-- trended session volume
SELECT MIN(DATE(created_at)) AS week_start_date, COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-05-10' AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at)
;

-- conv rate by device type
SELECT device_type, COUNT(DISTINCT w.website_session_id) AS sessions, COUNT(DISTINCT o.order_id) AS orders, COUNT(DISTINCT o.order_id)/COUNT(DISTINCT w.website_session_id) AS session_to_order_conv_rate
FROM website_sessions AS w
LEFT JOIN orders AS o
ON w.website_session_id = o.website_session_id
WHERE w.created_at < '2012-05-11' AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY 1;

-- trended session volume by device type
SELECT MIN(DATE(created_at)) AS week_start_date, 
COUNT(CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS dtop_sessions,
COUNT(CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS dtop_sessions
FROM website_sessions
WHERE created_at < '2012-06-09' AND created_at > '2012-04-15' AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);
-- conclusion: bid up for desktop got more session to the website
-- next step: continue to monitor device-level volume and be aware of the impact of bid;
-- continue to monitor conversion performance by device type to optimize spend


-- pull the most viewed website pages
SELECT pageview_url, COUNT(DISTINCT website_session_id) AS sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY 1
ORDER by 2 DESC;
-- conclusion: home, products, and mr.fuzzy page gets the most views
-- next step: does this list also represents the top entry pages?
-- analyze the performance of each page


-- pull the top entry page
-- find the entry page id for each session
CREATE TEMPORARY TABLE entry_page
SELECT MIN(website_pageview_id) AS entry_page_id, website_session_id
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id;

-- count sessions for each entry page 
SELECT pageview_url AS landing_page, COUNT(e.website_session_id) AS sessions
FROM entry_page AS e
JOIN website_pageviews AS w
ON e.entry_page_id = w.website_pageview_id
GROUP BY 1;
-- conclusion: all traffic is through home page
-- next step: home page performance
-- think about if home page is the best initial experience


-- calculate bounce rate for home page

-- step 1: find the landing page for each session
CREATE TEMPORARY TABLE landing_page
SELECT MIN(website_pageview_id) AS landing_page_id, website_session_id
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id;

-- step 2: identify the session with home as the landing page
CREATE TEMPORARY TABLE home_landing
SELECT l.website_session_id AS session_id, pageview_url
FROM landing_page AS l
JOIN website_pageviews AS w
ON  l.landing_page_id = w.website_pageview_id
WHERE pageview_url = '/home';

-- step 3: identify bounced sessions
CREATE TEMPORARY TABLE bounced_sessions
SELECT website_session_id AS bounced_sessions, h.pageview_url, COUNT(website_pageview_id)
FROM home_landing AS h
JOIN website_pageviews AS w
ON h.session_id = w.website_session_id
GROUP BY h.session_id, h.pageview_url
HAVING COUNT(website_pageview_id) = 1;

-- step 4: count the total and bounced sessions
SELECT COUNT(l.website_session_id) AS sessions, 
COUNT(b.bounced_sessions) AS bounced_sessions, 
COUNT(b.bounced_sessions)/COUNT(l.website_session_id) AS bounce_rate
FROM landing_page AS l
LEFT JOIN bounced_sessions AS b
ON l.website_session_id = b.bounced_sessions;


-- calculate bounced rate for home page and a new lander page

-- find the first instance of /lander-1 to set the timeframe
SELECT MIN(created_at) AS first_created_at, MIN(website_pageview_id) AS frist_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
GROUP BY pageview_url;
-- conclusion: data should be pulled between 2012-06-19 and 2012-07-28(current date)

-- step 1: find the landing page for all sessions for gsearch nonbrand traffic
DROP TABLE IF EXISTS landing_page;
CREATE TEMPORARY TABLE landing_page
SELECT MIN(website_pageview_id) AS landing_page_id, p.website_session_id AS website_session_id
FROM website_pageviews AS p
JOIN website_sessions AS s
ON p.website_session_id = s.website_session_id
WHERE p.created_at < '2012-07-28' AND p.created_at > '2012-06-19' 
AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY p.website_session_id;

-- step 2: find the pages with home and /lander-1 as the landing page
DROP TABLE IF EXISTS home_lander_as_landing_page;
CREATE TEMPORARY TABLE home_lander_as_landing_page
SELECT l.website_session_id AS website_session_id, pageview_url
FROM landing_page AS l
JOIN website_pageviews AS w
ON l.landing_page_id = w.website_pageview_id
WHERE pageview_url = '/home' OR pageview_url ='/lander-1';

-- step 3: find the bounced sessions for both pages
DROP TABLE IF EXISTS bounced_sessions;
CREATE TEMPORARY TABLE bounced_sessions
SELECT h.website_session_id AS website_session_id, h.pageview_url AS pageview_url
FROM home_lander_as_landing_page AS h
JOIN website_pageviews AS w
ON h.website_session_id = w.website_session_id
GROUP BY h.website_session_id, h.pageview_url
HAVING COUNT(h.pageview_url) = 1;

-- step 4: calculate total sessions and bounced sessions for both pages
SELECT h.pageview_url AS landing_page, 
COUNT(h.website_session_id) AS total_sessions, 
COUNT(b.website_session_id) AS bounced_sessions,
COUNT(b.website_session_id)/COUNT(h.website_session_id) AS bounce_rate
FROM home_lander_as_landing_page AS h
LEFT JOIN bounced_sessions AS b
ON h.website_session_id = b.website_session_id
GROUP BY h.pageview_url;
-- conclusion: new lander page has a better bounce rate(0.58) compared with home page(0.53)


-- landing page trend analysis

-- find the sessions that are gearch and nonbrand， and find the landing page for each sessions 
CREATE TEMPORARY TABLE landing_page
SELECT p.website_session_id AS website_session_id, MIN(website_pageview_id) AS landing_page, COUNT(website_pageview_id) AS page_view_count
FROM website_pageviews p
JOIN website_sessions s
ON p.website_session_id = s.website_session_id
WHERE p.created_at < '2012-08-30' AND p.created_at > '2012-06-01' 
AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY p.website_session_id;

-- find sessions with home / lander-1 as the landing page 
CREATE TEMPORARY TABLE landing_page_W_page_name_and_created_at
SELECT l.website_session_id AS website_session_id, landing_page, page_view_count, pageview_url, created_at
FROM landing_page l
LEFT JOIN website_pageviews p
ON l.landing_page = p.website_pageview_id;
-- calculate overall paid search bounce rate
SELECT MIN(DATE(created_at)) AS week_start_date, 
COUNT(CASE WHEN page_view_count = 1 THEN website_session_id ELSE NULL END)/COUNT(website_session_id) AS bounce_rate, 
COUNT(CASE WHEN pageview_url = '/home' THEN website_session_id ELSE NULL END) AS home_traffic,
COUNT(CASE WHEN pageview_url = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_traffic
FROM landing_page_W_page_name_and_created_at

GROUP BY YEARWEEK(created_at);

-- conversion funnel analysis: what persentage of users move on to the next step
-- clickthrough rate
-- subquery: 
-- must be a complete query on its own
-- must give it  an alias
-- an be hard to follow for multi-step analyses
-- select all pageviews

SELECT p.website_session_id AS website_session_id, 
website_pageview_id, 
pageview_url,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS to_products,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS to_mrfuzzy,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS to_cart,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS to_shipping,
CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS to_billing,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS to_thankyou
FROM website_pageviews p
JOIN website_sessions s
ON p.website_session_id = s.website_session_id
WHERE p.created_at < '2012-09-05' AND p.created_at > '2012-08-05' 
AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
ORDER BY p.website_session_id, p.created_at;

-- create session level conversion funnel view
CREATE TEMPORARY TABLE page_made_to
SELECT website_session_id,
MAX(to_products) AS products_made_to,
MAX(to_mrfuzzy) AS mrfuzzy_made_to,
MAX(to_cart) AS cart_made_to,
MAX(to_shipping) AS shipping_made_to,
MAX(to_billing) AS billing_made_to,
MAX(to_thankyou) AS thankyou_made_to
FROM (
SELECT p.website_session_id AS website_session_id, 
website_pageview_id, 
pageview_url,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS to_products,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS to_mrfuzzy,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS to_cart,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS to_shipping,
CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS to_billing,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS to_thankyou
FROM website_pageviews p
JOIN website_sessions s
ON p.website_session_id = s.website_session_id
WHERE p.created_at < '2012-09-05' AND p.created_at > '2012-08-05' 
AND utm_source = 'gsearch' 
AND pageview_url IN ('/lander-1','/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
ORDER BY p.website_session_id, p.created_at
) AS page_level
GROUP BY website_session_id;

-- aggregate data to assess funnel performance
-- total clicks
SELECT COUNT(website_session_id) AS sessions,
SUM(products_made_to) AS to_products,
SUM(mrfuzzy_made_to) AS to_mr_fuzzy,
SUM(cart_made_to) AS to_cart,
SUM(shipping_made_to) AS to_shipping,
SUM(billing_made_to) AS to_billing,
SUM(thankyou_made_to) AS to_thankyou
FROM page_made_to;
-- clickthrough rate
SELECT SUM(products_made_to)/COUNT(website_session_id) AS lander_click_rt,
SUM(mrfuzzy_made_to)/SUM(products_made_to) AS products_click_rt,
SUM(cart_made_to)/SUM(mrfuzzy_made_to) AS mr_fuzzy_rt,
SUM(shipping_made_to)/SUM(cart_made_to) AS cart_click_rt,
SUM(billing_made_to)/SUM(shipping_made_to) AS shipping_click_rt,
SUM(thankyou_made_to)/SUM(billing_made_to) AS billing_click_rt
FROM page_made_to;

-- conclusion: lander, mrfuzzy, and billing has the lowest click rate

-- find the first time /billing-2 was seen
SELECT created_at, pageview_url
FROM website_pageviews
WHERE pageview_url = '/billing-2'
ORDER BY created_at LIMIT 1;
-- first seen time stamp 2012-09-10 01:13:05

-- conversion funnel analysis
-- flag pageview
SELECT
pageview_url,
COUNT(website_session_id) AS sessions,
COUNT(order_id) AS orders,
COUNT(order_id)/COUNT(website_session_id) AS bulling_to_order_rt
FROM (
SELECT p.website_session_id AS website_session_id, 
pageview_url,order_id
FROM website_pageviews p
LEFT JOIN orders o
ON p.website_session_id = o.website_session_id
WHERE p.created_at < '2012-11-10' AND p.created_at > '2012-09-10' AND pageview_url IN ('/billing', '/billing-2')
ORDER BY p.website_session_id, p.created_at
) AS session_w_order
GROUP BY pageview_url;
-- conclusion: the new /billing-2 page is doing a better job converting customers. Roll out the new version to 100% traffic.

-- pull monthly trends for gsearch sessions and orders
SELECT YEAR(s.created_at) AS years, 
MONTH(s.created_at) AS months, 
COUNT(s.website_session_id) AS sessions, 
COUNT(order_id) AS orders
FROM website_sessions s
LEFT JOIN orders o
ON s.website_session_id = o.website_session_id
WHERE s.created_at < '2012-11-27' AND utm_source = 'gsearch' 
GROUP BY 1,2;
-- conclusion: see substantial growth for sessions and orders.

-- dive into gsearch nonbrand, and pull month sessions and orders split by device type
SELECT YEAR(s.created_at) AS years, 
MONTH(s.created_at) AS months, 
COUNT(CASE WHEN device_type = 'desktop' THEN s.website_session_id ELSE NULL END) AS desktop_sessions, 
COUNT(CASE WHEN device_type = 'mobile' THEN s.website_session_id ELSE NULL END) AS mobile_sessions,
COUNT(CASE WHEN device_type = 'desktop' THEN order_id ELSE NULL END) AS desktop_orders,
COUNT(CASE WHEN device_type = 'mobile' THEN order_id ELSE NULL END) AS mobile_orders

FROM website_sessions s
LEFT JOIN orders o
ON s.website_session_id = o.website_session_id
WHERE s.created_at < '2012-11-27' AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY 1,2;
-- conclusion: desktop to mobile ratio increased from around 5:1 to 10:1

-- session to order conversion rate by month
SELECT YEAR(s.created_at) AS year, MONTH(s.created_at) AS month, COUNT(order_id)/COUNT(s.website_session_id) AS conversion_rate
FROM website_sessions s
LEFT JOIN orders o
ON s.website_session_id = o.website_session_id
WHERE s.created_at < '2012-11-27'
GROUP BY 1,2;
-- conclusion: session to order conversion rate increased from 3% to 4%

-- show a full conversion funnel from each of the two pages (home & lander-1) to orders
CREATE TEMPORARY TABLE page_made_to
SELECT website_session_id,
MAX(lander1) AS lander1_made_to,
MAX(home) AS home_made_to,
MAX(products) AS products_made_to,
MAX(mrfuzzy) AS mrfuzzy_made_to,
MAX(cart) AS cart_made_to,
MAX(shipping) AS shipping_made_to,
MAX(billing) AS billing_made_to,
MAX(thankyou) AS thankyou_made_to
FROM (
SELECT p.website_session_id AS website_session_id, 
pageview_url,
CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander1,
CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS home,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping,
CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou
FROM website_pageviews p
JOIN website_sessions s
ON p.website_session_id = s.website_session_id
WHERE p.created_at > '2012-06-19' AND p.created_at < '2012-07-28'
AND utm_source = 'gsearch' 
AND utm_campaign = 'nonbrand' 
ORDER BY p.website_session_id, p.created_at
) AS page_level
GROUP BY website_session_id;

SELECT 
CASE 
WHEN home_made_to = 1 THEN 'saw_home'
WHEN lander1_made_to = 1 THEN 'saw_lander1'
ELSE NULL END AS segment,
COUNT(website_session_id) AS sessions,
SUM(products_made_to) AS to_products,
SUM(mrfuzzy_made_to) AS to_mr_fuzzy,
SUM(cart_made_to) AS to_cart,
SUM(shipping_made_to) AS to_shipping,
SUM(billing_made_to) AS to_billing,
SUM(thankyou_made_to) AS to_thankyou
FROM page_made_to
GROUP BY 1;

-- quantify the impact of the new billing page (/billing-2) in terms of revenue per billing page session
SELECT pageview_url, COUNT(p.website_session_id) AS sessions,
SUM(price_usd)/COUNT(p.website_session_id) AS revenue_per_billing_page
FROM website_pageviews p
LEFT JOIN orders o
ON p.website_session_id = o.website_session_id
WHERE p.created_at < '2012-11-10' AND p.created_at > '2012-09-10' AND pageview_url IN ('/billing', '/billing-2')
GROUP BY 1;
-- conclusion: major lift in revenue coming from billing-2

-- channel portfolio optimization
-- analyze the porformace of expanded channel bsearch
SELECT MIN(DATE(created_at)),
COUNT(CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
COUNT(CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions

FROM website_sessions

WHERE created_at < '2012-11-29' AND created_at > '2012-08-22' AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);
-- conclusion: bsearch tends to get a thrid the traffic of gsearch

-- compaing the gsearch and bsearch channels
SELECT utm_source,
COUNT(website_session_id) AS sessions,
COUNT(CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
COUNT(CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END)/COUNT(website_session_id) AS percent_mobile
FROM website_sessions
WHERE created_at < '2012-11-30' AND created_at > '2012-08-22' AND utm_campaign = 'nonbrand'
GROUP BY utm_source;
-- conclusion: the channels are quite differnt from a device standpoint