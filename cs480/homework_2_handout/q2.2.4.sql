WITH visit_seasons AS (
    SELECT c.city_id, c.name AS cityname,
           CASE WHEN EXTRACT(MONTH FROM sv.visit_date) IN (12, 1, 2) THEN 'Winter'
                WHEN EXTRACT(MONTH FROM sv.visit_date) IN (3, 4, 5) THEN 'Spring'
                WHEN EXTRACT(MONTH FROM sv.visit_date) IN (6, 7, 8) THEN 'Summer'
                WHEN EXTRACT(MONTH FROM sv.visit_date) IN (9, 10, 11) THEN 'Fall'
           END AS season,
           COUNT(*) AS numvisits
    FROM public.sitevisit sv
    JOIN public.famoussite f ON sv.site_id = f.site_id
    JOIN public.city c ON f.city_id = c.city_id
    GROUP BY c.city_id, c.name, season
),
ranked AS (
    SELECT city_id, cityname, season, numvisits,
           ROW_NUMBER() OVER (PARTITION BY city_id ORDER BY numvisits DESC, season) AS rn
    FROM visit_seasons
)
SELECT city_id, cityname, season, numvisits
FROM ranked
WHERE rn = 1;