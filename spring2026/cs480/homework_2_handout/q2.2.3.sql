SELECT f.site_id, f.name,
       COUNT(DISTINCT t.traveler_id) AS travelerfootprint,
       COALESCE(SUM(tr.amount_usd), 0) AS revenue
FROM public.famoussite f
LEFT JOIN public.sitevisit sv ON f.site_id = sv.site_id
LEFT JOIN public.trip trp ON sv.trip_id = trp.trip_id
LEFT JOIN public.traveler t ON trp.traveler_id = t.traveler_id
LEFT JOIN public.transaction tr ON f.site_id = tr.site_id
WHERE f.unesco = TRUE
GROUP BY f.site_id, f.name
ORDER BY travelerfootprint DESC, revenue DESC
LIMIT 3;