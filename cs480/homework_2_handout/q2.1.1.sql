ALTER TABLE public.trip
ADD COLUMN month integer NOT NULL DEFAULT 0
CHECK (month = 0 OR month BETWEEN 1 AND 12);

UPDATE public.trip
SET month = EXTRACT(MONTH FROM start_date)::integer;
