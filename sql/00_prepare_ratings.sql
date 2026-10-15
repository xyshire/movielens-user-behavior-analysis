-- MovieLens 25M: Prepare the ratings analysis table
--
-- Prerequisites:
-- 1. Upload movies.csv to movielens_analytics.movies
-- 2. Split ratings.csv into 10 CSV files
-- 3. Upload them as ratings_part_01 through ratings_part_10
--
-- BigQuery Standard SQL

CREATE OR REPLACE TABLE
    `app-user-analytics.movielens_analytics.ratings`
AS
SELECT
    CAST(userId AS INT64) AS user_id,
    CAST(movieId AS INT64) AS movie_id,
    CAST(rating AS FLOAT64) AS rating,
    CAST(timestamp AS INT64) AS rating_timestamp,
    DATE(
        TIMESTAMP_SECONDS(CAST(timestamp AS INT64))
    ) AS rating_date
FROM
    `app-user-analytics.movielens_analytics.ratings_part_*`;
