-- MovieLens 25M: User Activity Segmentation
-- Source: app-user-analytics.movielens_analytics.ratings
-- Activity is defined as cumulative rating count,
-- NOT viewing activity or platform retention.

WITH user_activity AS (
    SELECT
        user_id,
        COUNT(*) AS rating_count
    FROM `app-user-analytics.movielens_analytics.ratings`
    GROUP BY user_id
),

ranked_users AS (
    SELECT
        user_id,
        rating_count,
        PERCENT_RANK() OVER (
            ORDER BY rating_count
        ) AS activity_rank
    FROM user_activity
),

segmented_users AS (
    SELECT
        user_id,
        rating_count,
        CASE
            WHEN activity_rank < 0.50 THEN '1_Low'
            WHEN activity_rank < 0.75 THEN '2_Medium'
            WHEN activity_rank < 0.90 THEN '3_High'
            ELSE '4_Core'
        END AS user_segment
    FROM ranked_users
)

SELECT
    user_segment,
    COUNT(*) AS user_count,
    ROUND(
        100 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS user_pct,
    SUM(rating_count) AS total_ratings,
    ROUND(
        100 * SUM(rating_count) /
        SUM(SUM(rating_count)) OVER (),
        2
    ) AS rating_contribution_pct,
    ROUND(AVG(rating_count), 2) AS avg_ratings_per_user
FROM segmented_users
GROUP BY user_segment
ORDER BY user_segment;
