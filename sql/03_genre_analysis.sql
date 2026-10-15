-- MovieLens 25M: Genre-Level Rating Analysis
-- Movies may belong to multiple genres.
-- A rating is counted once for each associated genre.
-- Rating counts across genres are therefore not additive.

WITH movie_genres AS (
    SELECT
        movieId AS movie_id,
        TRIM(genre) AS genre
    FROM
        `app-user-analytics.movielens_analytics.movies`,
        UNNEST(SPLIT(genres, '|')) AS genre
    WHERE genre != '(no genres listed)'
),

genre_ratings AS (
    SELECT
        g.genre,
        r.user_id,
        r.movie_id,
        r.rating
    FROM
        `app-user-analytics.movielens_analytics.ratings` r
    JOIN movie_genres g
        ON r.movie_id = g.movie_id
)

SELECT
    genre,
    COUNT(*) AS rating_count,
    COUNT(DISTINCT user_id) AS unique_raters,
    COUNT(DISTINCT movie_id) AS rated_movies,
    ROUND(AVG(rating), 3) AS avg_rating
FROM genre_ratings
GROUP BY genre
ORDER BY rating_count DESC;
