WITH european_countries AS (
    SELECT country_id
    FROM public.country
    WHERE continent = 'Europe'
),
total_european AS (
    SELECT COUNT(*) AS cnt
    FROM european_countries
),
qualifying_cities AS (
    SELECT DISTINCT co.country_id, c.city_id
    FROM public.country co
    JOIN public.city c ON co.country_id = c.country_id
    JOIN public.famoussite f ON c.city_id = f.city_id
),
covered AS (
    SELECT t.traveler_id, ec.country_id
    FROM public.traveler t
    CROSS JOIN european_countries ec
    WHERE NOT EXISTS (
        SELECT 1
        FROM qualifying_cities qc
        WHERE qc.country_id = ec.country_id
        AND NOT (
            EXISTS (
                SELECT 1
                FROM public.sitevisit sv
                JOIN public.trip tr ON sv.trip_id = tr.trip_id
                WHERE tr.traveler_id = t.traveler_id
                AND sv.site_id IN (SELECT site_id FROM public.famoussite WHERE city_id = qc.city_id)
            )
            AND EXISTS (
                SELECT 1
                FROM public.sitevisit sv
                JOIN public.trip tr ON sv.trip_id = tr.trip_id
                WHERE tr.traveler_id = t.traveler_id
                AND sv.site_id IN (SELECT site_id FROM public.famoussite WHERE city_id = qc.city_id)
                AND sv.minutes_spent >= 60
            )
        )
    )
)
SELECT t.traveler_id, t.name
FROM public.traveler t
WHERE (
    SELECT COUNT(*)
    FROM covered c
    WHERE c.traveler_id = t.traveler_id
) = (SELECT cnt FROM total_european);