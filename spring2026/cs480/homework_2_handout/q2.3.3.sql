WITH country_stats AS (
    SELECT co.country_id, COUNT(t.transaction_id) AS trans_count, MAX(t.amount_usd) AS max_amount
    FROM public.country co
    LEFT JOIN public.city c ON co.country_id = c.country_id
    LEFT JOIN public.famoussite f ON c.city_id = f.city_id
    LEFT JOIN public.transaction t ON f.site_id = t.site_id
    GROUP BY co.country_id
    HAVING COUNT(t.transaction_id) >= 2
)
DELETE FROM public.transaction
WHERE transaction_id IN (
    SELECT t.transaction_id
    FROM public.transaction t
    JOIN public.famoussite f ON t.site_id = f.site_id
    JOIN public.city c ON f.city_id = c.city_id
    JOIN country_stats cs ON c.country_id = cs.country_id
    WHERE t.amount_usd = cs.max_amount
);