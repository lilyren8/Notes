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
