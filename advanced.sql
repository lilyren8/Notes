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





