ALTER TABLE public.famoussite ADD COLUMN is_top_site boolean NOT NULL DEFAULT false;

WITH site_revenue AS (
    SELECT f.site_id, c.country_id, COALESCE(SUM(t.amount_usd), 0) AS revenue
    FROM public.famoussite f
    JOIN public.city c ON f.city_id = c.city_id
    LEFT JOIN public.transaction t ON f.site_id = t.site_id
    GROUP BY f.site_id, c.country_id
),
ranked_sites AS (
    SELECT site_id, ROW_NUMBER() OVER (PARTITION BY country_id ORDER BY revenue DESC) AS rnk
    FROM site_revenue
)
UPDATE public.famoussite
SET is_top_site = true
WHERE site_id IN (
    SELECT site_id
    FROM ranked_sites
    WHERE rnk <= 2
);