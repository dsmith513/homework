WITH footprint AS (
    SELECT sv.site_id,
           COUNT(DISTINCT trp.traveler_id) AS travelerfootprint
    FROM public.sitevisit sv
    JOIN public.trip trp
      ON sv.trip_id = trp.trip_id
    GROUP BY sv.site_id
),
revenue AS (
    SELECT tr.site_id,
           SUM(tr.amount_usd) AS revenue
    FROM public.transaction tr
    GROUP BY tr.site_id
)
SELECT f.site_id,
       f.name,
       COALESCE(fp.travelerfootprint, 0) AS travelerfootprint,
       COALESCE(r.revenue, 0) AS revenue
FROM public.famoussite f
LEFT JOIN footprint fp
  ON f.site_id = fp.site_id
LEFT JOIN revenue r
  ON f.site_id = r.site_id
WHERE f.unesco = TRUE
ORDER BY travelerfootprint DESC, revenue DESC
FETCH FIRST 3 ROWS WITH TIES;