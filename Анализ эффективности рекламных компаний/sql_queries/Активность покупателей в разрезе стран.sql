SELECT 
country,
COUNT(DISTINCT events.user_id) AS users,
COUNT(event_id) AS all_events,
COUNT(event_id) FILTER (WHERE event_type = 'Impression') as impressions,
COUNT(event_id) FILTER (WHERE event_type = 'Click') as clicks,
COUNT(event_id) FILTER (WHERE event_type = 'Like') as likes,
COUNT(event_id) FILTER (WHERE event_type = 'Comment') as comments,
COUNT(event_id) FILTER (WHERE event_type = 'Purchase') as purchases,
COUNT(event_id) FILTER (WHERE event_type = 'Share') as shares,
	ROUND(COUNT(event_id) FILTER (WHERE event_type = 'Click')*1.0/COUNT(event_id) FILTER (WHERE event_type = 'Impression'), 4) as CTR,
    ROUND(COUNT(DISTINCT CASE WHEN event_type = 'Purchase' THEN events.user_id END)::numeric / 
          NULLIF(COUNT(DISTINCT events.user_id), 0), 4) AS CR,
	ROUND(COUNT(event_id) FILTER (WHERE event_type IN ('Like', 'Comment', 'Share'))* 1.0 / NULLIF(COUNT(DISTINCT events.user_id), 0), 4) AS ER
FROM events
LEFT JOIN ads ON ads.ad_id = events.ad_id
LEFT JOIN campaigns ON campaigns.campaign_id = ads.campaign_id
LEFT JOIN users ON users.user_id = events.user_id
GROUP BY country