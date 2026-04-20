WITH city_pairs AS (
    SELECT c1.city_id AS city_id1, c1.name AS city_name1,
           c2.city_id AS city_id2, c2.name AS city_name2,
           2 * 6371 * ASIN(SQRT(
               SIN(RADIANS(c2.latitude - c1.latitude) / 2)^2 +
               COS(RADIANS(c1.latitude)) * COS(RADIANS(c2.latitude)) *
               SIN(RADIANS(c2.longitude - c1.longitude) / 2)^2
           )) AS distance_km,
           (SELECT COALESCE(SUM(t.amount_usd), 0)
            FROM public.transaction t
            JOIN public.famoussite f ON t.site_id = f.site_id
            WHERE f.city_id = c1.city_id) +
           (SELECT COALESCE(SUM(t.amount_usd), 0)
            FROM public.transaction t
            JOIN public.famoussite f ON t.site_id = f.site_id
            WHERE f.city_id = c2.city_id) AS combinedrevenue
    FROM public.city c1
    JOIN public.city c2 ON c1.city_id < c2.city_id
    WHERE 2 * 6371 * ASIN(SQRT(
              SIN(RADIANS(c2.latitude - c1.latitude) / 2)^2 +
              COS(RADIANS(c1.latitude)) * COS(RADIANS(c2.latitude)) *
              SIN(RADIANS(c2.longitude - c1.longitude) / 2)^2
          )) <= 3000
),
max_revenue AS (
    SELECT MAX(combinedrevenue) AS max_combined
    FROM city_pairs
)
SELECT LEAST(city_name1, city_name2) AS city_name1,
       GREATEST(city_name1, city_name2) AS city_name2,
       distance_km,
       combinedrevenue
FROM city_pairs
WHERE combinedrevenue = (SELECT max_combined FROM max_revenue)
ORDER BY city_name1, city_name2;