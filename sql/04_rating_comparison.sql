-- MovieLens 25M: Within-Movie Rating Comparison
-- Compare Low vs Core activity segments.
-- Only include movies with at least 20 ratings
-- from each of the two segments.
--
-- This is an observational comparison.
-- It does not establish causality.

WITH user_activity AS (
    SELECT
        user_id,
        COUNT(*) AS rating_count
    FROM
        `app-user-analytics.movielens_analytics.ratings`
    GROUP BY user_id
),

ranked_users AS (
    SELECT
        user_id,
        PERCENT_RANK() OVER (
            ORDER BY rating_count
        ) AS activity_rank
    FROM user_activity
),

user_segments AS (
    SELECT
        user_id,
        CASE
            WHEN activity_rank < 0.50 THEN '1_Low'
            WHEN activity_rank < 0.75 THEN '2_Medium'
            WHEN activity_rank < 0.90 THEN '3_High'
            ELSE '4_Core'
        END AS user_segment
    FROM ranked_users
),

movie_segment_scores AS (
    SELECT
        r.movie_id,
        s.user_segment,
        COUNT(*) AS rating_count,
        AVG(r.rating) AS avg_rating
    FROM
        `app-user-analytics.movielens_analytics.ratings` r
    JOIN user_segments s
        ON r.user_id = s.user_id
    WHERE s.user_segment IN ('1_Low', '4_Core')
    GROUP BY r.movie_id, s.user_segment
),

movie_comparison AS (
    SELECT
        movie_id,
        MAX(
            IF(user_segment = '1_Low', avg_rating, NULL)
        ) AS low_avg,
        MAX(
            IF(user_segment = '4_Core', avg_rating, NULL)
        ) AS core_avg,
        MAX(
            IF(user_segment = '1_Low', rating_count, NULL)
        ) AS low_count,
        MAX(
            IF(user_segment = '4_Core', rating_count, NULL)
        ) AS core_count
    FROM movie_segment_scores
    GROUP BY movie_id
)

SELECT
    COUNT(*) AS compared_movies,
    ROUND(AVG(core_avg - low_avg), 3)
        AS avg_core_minus_low,
    ROUND(
        100 * COUNTIF(core_avg < low_avg) / COUNT(*),
        2
    ) AS pct_movies_core_lower,
    ROUND(
        100 * COUNTIF(core_avg > low_avg) / COUNT(*),
        2
    ) AS pct_movies_core_higher
FROM movie_comparison
WHERE low_count >= 20
  AND core_count >= 20;
