
ALTER TABLE public.trip
  ADD COLUMN month int NOT NULL DEFAULT 0
    CHECK (month BETWEEN 0 AND 12);

UPDATE public.trip
   SET month = EXTRACT(MONTH FROM start_date);

