WITH site_revenues AS (
    SELECT f.site_id,
           COALESCE(SUM(t.amount_usd), 0) AS total_revenue,
           COALESCE(SUM(CASE WHEN t.payment_method = 'card' THEN t.amount_usd ELSE 0 END), 0) AS card_revenue,
           COALESCE(SUM(CASE WHEN t.payment_method = 'cash' THEN t.amount_usd ELSE 0 END), 0) AS cash_revenue
    FROM public.famoussite f
    LEFT JOIN public.transaction t ON f.site_id = t.site_id
    GROUP BY f.site_id
),
payment_type_revenue AS (
    SELECT f.site_id, t.payment_method, SUM(t.amount_usd) AS rev
    FROM public.famoussite f
    JOIN public.transaction t ON f.site_id = t.site_id
    GROUP BY f.site_id, t.payment_method
),
ranked AS (
    SELECT site_id, payment_method, rev,
           RANK() OVER (PARTITION BY site_id ORDER BY rev DESC) AS rnk
    FROM payment_type_revenue
)
SELECT sr.site_id, sr.total_revenue, sr.card_revenue, sr.cash_revenue,
       CASE WHEN sr.total_revenue = 0 THEN 0 ELSE sr.card_revenue / sr.total_revenue END AS card_share,
       CASE WHEN sr.total_revenue = 0 THEN 0 ELSE sr.cash_revenue / sr.total_revenue END AS cash_share,
       r.payment_method AS top_payment_type
FROM site_revenues sr
LEFT JOIN ranked r ON sr.site_id = r.site_id AND r.rnk = 1
ORDER BY sr.total_revenue DESC;