## ANALYZING TRAFFIC SOURCE

/* Dertermine the the number of session logS that has been converted into a sales orders 
and the precentage of these order comparing to number of sesions*/
SELECT UTM_CONTENT , COUNT( DISTINCT ws.website_session_id) AS Number_Of_Sessions,
		COUNT(DISTINCT o.order_id) AS Number_Of_Orders,
		CONCAT(((COUNT(DISTINCT o.order_id) / COUNT( DISTINCT ws.website_session_id)) *100),' %') AS From_Orders_To_Sales
FROM website_sessions AS ws
LEFT JOIN orders as o ON ws.website_session_id = o.website_session_id
GROUP BY UTM_CONTENT;


/* We've been live for almost a month now and we’re starting to generate sales. Can you help me understand
where the bulk of our website sessions are coming from, through yesterday? I’d like to see a breakdown by
UTM source , campaign and referring domain if possible. Thanks! */

SELECT utm_source , utm_campaign, http_referer , COUNT(DISTINCT website_session_id) AS  Sessions
FROM website_sessions
WHERE created_at < '2012-04-12' # THE DATE OF THE ABOVE REQUEST
GROUP BY utm_source , utm_campaign , http_referer
ORDER BY Sessions DESC;

/*Sounds like gsearch nonbrand is our major traffic source, but we need to understand if those sessions are driving sales. 
Could you please calculate the conversion rate (CVR) from session to order ? Based on what we're paying for clicks,
we’ll need a CVR of at least 4% to make the numbers work. If we're much lower, we’ll need to reduce bids. If we’re higher, 
we can increase bids to drive more volume. */
SELECT COUNT( DISTINCT ws.website_session_id) as sessions , 
		COUNT(DISTINCT order_id) as orders,
        CONCAT(round((COUNT(DISTINCT order_id) / COUNT( DISTINCT ws.website_session_id)) * 100,2),' %') AS session_to_order_con_rate
FROM website_sessions ws
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2012-04-14' 
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand';

/* Count the number of items purchased by the number of items, if the customer purchased one or two items,
Then group by the year, and the count of each number in each year*/
SELECT 
YEAR(created_at) AS YEAR,
	COUNT( DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS one_order_id ,
	COUNT( DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS two_order_id , 
	COUNT( DISTINCT CASE WHEN items_purchased = 1 OR items_purchased = 2 THEN order_id END) AS GRAND
FROM orders
GROUP BY 1;
    
    
/* Based on your conversion rate analysis, we bid down gsearch nonbrand on 2012 04 15. Can you pull gsearch nonbrand trended 
session volume, by week , to see if the bid changes have caused volume to drop at all?  */
SELECT 	MIN(DATE(created_at)) AS Week_start_date, 
		COUNT(DISTINCT website_session_id) AS Sessions
FROM website_sessions
WHERE created_at < '2012-05-19'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);

/* I was trying to use our site on my mobile device the other day, and the experience was not great. Could you pull
conversion rates from session to order , by device type ? If desktop performance is better than on mobile we may be
able to bid up for desktop specifically to get more volume? */

SELECT device_type ,
	COUNT(DISTINCT ws.website_session_id ) AS Sessions,
    COUNT(DISTINCT o.order_id ) AS Orders,	
    COUNT(DISTINCT o.order_id ) /
	COUNT(DISTINCT ws.website_session_id ) AS session_to_order_conv_rate
FROM website_sessions AS ws
LEFT JOIN orders AS o ON o.website_session_id = ws.website_session_id
WHERE ws.created_at < '2012-05-11'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY device_type

/* After your device level analysis of conversion rates, we realized desktop was doing well, so we bid our gsearch
nonbrand desktop campaigns up on 2012 05 19. Could you pull weekly trends for both desktop and mobile so we can see the 
impact on volume? You can use 2012 04 15 until the bid change as a baseline. */

SELECT MIN(DATE(created_at)) AS WEEKS , 
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS dtop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-04-15' AND '2012-06-09'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at)

