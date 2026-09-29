SELECT f.site_id,
       f.name,
       COUNT(DISTINCT t.traveler_id) AS numtravelers
FROM public.famoussite f
LEFT JOIN public.sitevisit sv
       ON f.site_id = sv.site_id
LEFT JOIN public.trip t
       ON sv.trip_id = t.trip_id
GROUP BY f.site_id, f.name
ORDER BY numtravelers DESC, f.site_id;