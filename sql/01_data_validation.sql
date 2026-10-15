-- MovieLens 25M: Data Validation
-- Source: GroupLens MovieLens 25M
-- This dataset records ratings, not views or clicks.

-- 1. Validate the ratings table
SELECT
    COUNT(*) AS total_ratings,
    COUNT(DISTINCT user_id) AS total_users,
    COUNT(DISTINCT movie_id) AS rated_movies,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    MIN(rating_date) AS earliest_rating_date,
    MAX(rating_date) AS latest_rating_date,
    ROUND(AVG(rating), 3) AS avg_rating
FROM
    `app-user-analytics.movielens_analytics.ratings`;

-- 2. Validate the movies table
SELECT
    COUNT(*) AS total_movies,
    COUNT(DISTINCT movieId) AS unique_movies
FROM
    `app-user-analytics.movielens_analytics.movies`;

-- 3. Check for unmatched movie IDs
SELECT
    COUNT(*) AS unmatched_ratings
FROM
    `app-user-analytics.movielens_analytics.ratings` r
LEFT JOIN
    `app-user-analytics.movielens_analytics.movies` m
    ON r.movie_id = m.movieId
WHERE m.movieId IS NULL;
