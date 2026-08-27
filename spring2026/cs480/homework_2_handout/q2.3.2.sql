DELETE FROM public.traveler
WHERE traveler_id NOT IN (
    SELECT DISTINCT traveler_id
    FROM public.trip
);