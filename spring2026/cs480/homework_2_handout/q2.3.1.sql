UPDATE public.transaction
SET amount_usd = ROUND(amount_usd * 1.1, 2)
WHERE site_id IN (
    SELECT f.site_id
    FROM public.famoussite f
    JOIN public.city c ON f.city_id = c.city_id
    JOIN public.country co ON c.country_id = co.country_id
    WHERE co.gdp_usd_billions > 3000
);