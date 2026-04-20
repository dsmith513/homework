SELECT f.site_id,
       f.name,
       COUNT(DISTINCT sv.trip_id) AS numtravelers
FROM public.famoussite f
LEFT JOIN public.sitevisit sv
       ON f.site_id = sv.site_id
GROUP BY f.site_id, f.name
ORDER BY numtravelers DESC;