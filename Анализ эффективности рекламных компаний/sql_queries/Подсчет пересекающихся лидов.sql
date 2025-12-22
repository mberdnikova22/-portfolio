WITH user_intersections AS (
    SELECT 
        DISTINCT events.user_id,
        campaigns.campaign_id,
        campaigns.name,
        (CASE 
            WHEN target_gender = 'All' THEN 1 
            WHEN target_gender <> 'All' AND target_gender = user_gender THEN 1 
            ELSE 0 
        END +
        CASE 
            WHEN target_age_group = 'All' THEN 1 
            WHEN target_age_group <> 'All' AND target_age_group = age_group THEN 1 
            ELSE 0 
        END +
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM unnest(string_to_array(users.interests, ',')) AS ui
                WHERE ui = ANY(string_to_array(ads.target_interests, ','))
            ) THEN 1 ELSE 0 
        END) AS matching_lead
    FROM events
    LEFT JOIN ads ON events.ad_id = ads.ad_id
    LEFT JOIN users ON events.user_id = users.user_id
    LEFT JOIN campaigns ON campaigns.campaign_id = ads.campaign_id
),
filtered_users AS (
    SELECT 
        user_id,
        campaign_id,
        name,
        matching_lead,
        COUNT(*) OVER (PARTITION BY user_id, campaign_id) AS total_intersections
    FROM user_intersections
)

SELECT 
    COUNT(DISTINCT user_id) AS lead_users,
    campaign_id, 
    name,
    matching_lead
FROM filtered_users
WHERE total_intersections = matching_lead OR matching_lead = 0
GROUP BY campaign_id, name, matching_lead
ORDER BY campaign_id, matching_lead;


