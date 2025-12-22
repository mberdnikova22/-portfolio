SELECT
    a.target_gender,
    a.target_age_group,
    COUNT(CASE WHEN ae.event_type = 'Impression' THEN 1 END) AS impressions,
    COUNT(CASE WHEN ae.event_type = 'Click' THEN 1 END) AS clicks,
    CASE 
        WHEN COUNT(CASE WHEN ae.event_type = 'Impression' THEN 1 END) = 0 THEN 0
        ELSE COUNT(CASE WHEN ae.event_type = 'Click' THEN 1 END)::float / COUNT(CASE WHEN ae.event_type = 'Impression' THEN 1 END) * 100
    END AS ctr_percentage
FROM events ae
JOIN ads a ON ae.ad_id = a.ad_id
GROUP BY a.target_gender, a.target_age_group
ORDER BY ctr_percentage DESC
