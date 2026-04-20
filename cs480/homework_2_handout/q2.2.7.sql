WITH country_revenue AS (
    SELECT co.country_id, COALESCE(SUM(t.amount_usd), 0) AS total_revenue
    FROM public.country co
    LEFT JOIN public.city c ON co.country_id = c.country_id
    LEFT JOIN public.famoussite f ON c.city_id = f.city_id
    LEFT JOIN public.transaction t ON f.site_id = t.site_id
    GROUP BY co.country_id
),
traveler_country_spend AS (
    SELECT co.country_id, tr.traveler_id, SUM(t.amount_usd) AS spend
    FROM public.country co
    JOIN public.city c ON co.country_id = c.country_id
    JOIN public.famoussite f ON c.city_id = f.city_id
    JOIN public.transaction t ON f.site_id = t.site_id
    JOIN public.trip tp ON t.trip_id = tp.trip_id
    JOIN public.traveler tr ON tp.traveler_id = tr.traveler_id
    GROUP BY co.country_id, tr.traveler_id
),
ranked_spend AS (
    SELECT country_id, traveler_id, spend,
           ROW_NUMBER() OVER (PARTITION BY country_id ORDER BY spend DESC) AS rn
    FROM traveler_country_spend
)
SELECT cr.country_id, cr.total_revenue,
       COALESCE(SUM(CASE WHEN rs.rn <= 2 THEN rs.spend END) / NULLIF(cr.total_revenue, 0), 0) AS top2_share,
       COALESCE(SUM(CASE WHEN rs.rn = 1 THEN rs.spend END) / NULLIF(cr.total_revenue, 0), 0) AS top1_share
FROM country_revenue cr
LEFT JOIN ranked_spend rs ON cr.country_id = rs.country_id
GROUP BY cr.country_id, cr.total_revenue;