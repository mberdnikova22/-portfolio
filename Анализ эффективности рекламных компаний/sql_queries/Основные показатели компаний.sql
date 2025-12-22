SELECT 
    ads.campaign_id,
    campaigns.name,
	duration_days,
	total_budget,
    COUNT(DISTINCT events.user_id) AS users,
    COUNT(event_id) FILTER (WHERE event_type = 'Impression') AS impressions,
    COUNT(event_id) FILTER (WHERE event_type = 'Like') AS likes,
    COUNT(event_id) FILTER (WHERE event_type = 'Comment') AS comments,
    COUNT(event_id) FILTER (WHERE event_type = 'Purchase') AS purchases,
    COUNT(event_id) FILTER (WHERE event_type = 'Share') AS shares,
	ROUND(COUNT(event_id) FILTER (WHERE event_type = 'Click')*1.0/COUNT(event_id) FILTER (WHERE event_type = 'Impression'), 2) as CTR,
    ROUND(COUNT(DISTINCT CASE WHEN event_type = 'Purchase' THEN events.user_id END)::numeric / 
          NULLIF(COUNT(DISTINCT user_id), 0), 4) AS CR,
	ROUND((total_budget/COUNT(event_id) FILTER (WHERE event_type = 'Impression'))*1000, 2) AS CPM,  
	ROUND(total_budget/COUNT(event_id) FILTER (WHERE event_type = 'Click'), 2) AS CPC,
	ROUND(total_budget/COUNT(DISTINCT events.user_id) FILTER (WHERE event_type = 'Purchase'), 2) AS CAC
FROM 
    events
LEFT JOIN 
    ads ON ads.ad_id = events.ad_id
LEFT JOIN 
    campaigns ON ads.campaign_id = campaigns.campaign_id
GROUP BY 
    ads.campaign_id, campaigns.name, duration_days, total_budget
