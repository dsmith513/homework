CREATE TABLE public.TravelerPreference (
    traveler_id text NOT NULL REFERENCES public.traveler(traveler_id),
    category text NOT NULL,
    interest_level integer NOT NULL CHECK (interest_level BETWEEN 1 AND 5),
    PRIMARY KEY (traveler_id, category)
);

