SELECT country_id, name
FROM public.country
WHERE (gdp_usd_billions / population_millions) < 35
  AND continent NOT ILIKE '%America%';