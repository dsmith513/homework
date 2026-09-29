WITH city_revenue AS (
    SELECT f.city_id,
           COALESCE(SUM(t.amount_usd), 0) AS revenue
    FROM public.famoussite f
    LEFT JOIN public.transaction t
      ON f.site_id = t.site_id
    GROUP BY f.city_id
),
city_pairs AS (
    SELECT c1.name AS city_name1,
           c2.name AS city_name2,
           ROUND(
             CAST(
               2 * 6371 * ASIN(SQRT(
                   SIN(RADIANS(c2.latitude - c1.latitude) / 2)^2 +
                   COS(RADIANS(c1.latitude)) * COS(RADIANS(c2.latitude)) *
                   SIN(RADIANS(c2.longitude - c1.longitude) / 2)^2
               )) AS numeric
             ),
             11
           ) AS distance_km,
           COALESCE(r1.revenue, 0) + COALESCE(r2.revenue, 0) AS combinedrevenue
    FROM public.city c1
    JOIN public.city c2
      ON c1.city_id < c2.city_id
    LEFT JOIN city_revenue r1
      ON c1.city_id = r1.city_id
    LEFT JOIN city_revenue r2
      ON c2.city_id = r2.city_id
    WHERE 2 * 6371 * ASIN(SQRT(
              SIN(RADIANS(c2.latitude - c1.latitude) / 2)^2 +
              COS(RADIANS(c1.latitude)) * COS(RADIANS(c2.latitude)) *
              SIN(RADIANS(c2.longitude - c1.longitude) / 2)^2
          )) <= 3000
),
best_revenue AS (
    SELECT MAX(combinedrevenue) AS max_combinedrevenue
    FROM city_pairs
)
SELECT city_name1,
       city_name2,
       distance_km,
       combinedrevenue
FROM city_pairs
WHERE combinedrevenue = (SELECT max_combinedrevenue FROM best_revenue)
ORDER BY city_name1, city_name2;