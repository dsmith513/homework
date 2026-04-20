WITH unesco_sites AS (
    SELECT COUNT(*) AS total_unesco
    FROM public.famoussite
    WHERE unesco = TRUE
),
traveler_visits AS (
    SELECT t.traveler_id, t.name, COUNT(DISTINCT sv.site_id) AS visited_unesco
    FROM public.traveler t
    JOIN public.trip tr ON t.traveler_id = tr.traveler_id
    JOIN public.sitevisit sv ON tr.trip_id = sv.trip_id
    JOIN public.famoussite f ON sv.site_id = f.site_id
    WHERE f.unesco = TRUE
    GROUP BY t.traveler_id, t.name
)
SELECT tv.traveler_id, tv.name
FROM traveler_visits tv
CROSS JOIN unesco_sites u
WHERE tv.visited_unesco = u.total_unesco;