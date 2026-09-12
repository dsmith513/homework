
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

-- ============================================================
-- CS480 / Spring 2026 
-- ============================================================
DROP TABLE IF EXISTS public.transaction CASCADE;
DROP TABLE IF EXISTS public.sitevisit CASCADE;
DROP TABLE IF EXISTS public.trip CASCADE;
DROP TABLE IF EXISTS public.traveler CASCADE;
DROP TABLE IF EXISTS public.famoussite CASCADE;
DROP TABLE IF EXISTS public.city CASCADE;
DROP TABLE IF EXISTS public.country CASCADE;
DROP TABLE IF EXISTS public.go_board CASCADE;

CREATE TABLE public.country (
  country_id           text PRIMARY KEY,
  name                 text NOT NULL,
  continent            text NOT NULL,
  population_millions  numeric(10,1) NOT NULL CHECK (population_millions > 0),
  gdp_usd_billions     numeric(12,0) NOT NULL CHECK (gdp_usd_billions >= 0)
);

ALTER TABLE public.country OWNER TO postgres;

CREATE TABLE public.city (
  city_id              text PRIMARY KEY,
  country_id           text NOT NULL REFERENCES public.country(country_id),
  name                 text NOT NULL,
  latitude             numeric(9,4)  NOT NULL CHECK (latitude BETWEEN -90 AND 90),
  longitude            numeric(9,4)  NOT NULL CHECK (longitude BETWEEN -180 AND 180),
  population_millions  numeric(10,1) NOT NULL CHECK (population_millions >= 0)
);

ALTER TABLE public.city OWNER TO postgres;

CREATE TABLE public.famoussite (
  site_id          text PRIMARY KEY,
  city_id          text NOT NULL REFERENCES public.city(city_id),
  name             text NOT NULL,
  category         text NOT NULL,
  unesco           boolean NOT NULL,
  year_established integer NOT NULL, 
  latitude         numeric(9,4) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
  longitude        numeric(9,4) NOT NULL CHECK (longitude BETWEEN -180 AND 180)
);

ALTER TABLE public.famoussite OWNER TO postgres;

CREATE TABLE public.traveler (
  traveler_id       text PRIMARY KEY,
  name              text NOT NULL,
  home_country_id   text NOT NULL REFERENCES public.country(country_id),
  birth_date        date NOT NULL,
  segment           text NOT NULL
);

ALTER TABLE public.traveler OWNER TO postgres;

CREATE TABLE public.trip (
  trip_id     text PRIMARY KEY,
  traveler_id text NOT NULL REFERENCES public.traveler(traveler_id),
  start_date  date NOT NULL,
  end_date    date NOT NULL,
  purpose     text NOT NULL,
  budget_usd  integer NOT NULL CHECK (budget_usd >= 0),
  CHECK (end_date >= start_date)
);

ALTER TABLE public.trip OWNER TO postgres;

CREATE TABLE public.sitevisit (
  trip_id        text NOT NULL REFERENCES public.trip(trip_id),
  site_id        text NOT NULL REFERENCES public.famoussite(site_id),
  visit_date     date NOT NULL,
  minutes_spent  integer NOT NULL CHECK (minutes_spent >= 0),
  group_size     integer NOT NULL CHECK (group_size >= 1),
  rating         integer CHECK (rating BETWEEN 1 AND 5),
  PRIMARY KEY (trip_id, site_id, visit_date)
);

ALTER TABLE public.sitevisit OWNER TO postgres;

CREATE TABLE public.transaction (
  transaction_id  text PRIMARY KEY,
  trip_id         text NOT NULL REFERENCES public.trip(trip_id),
  site_id         text NOT NULL REFERENCES public.famoussite(site_id),
  date            date NOT NULL,
  type            text NOT NULL,
  amount_usd      numeric(10,2) NOT NULL CHECK (amount_usd >= 0),
  payment_method  text NOT NULL CHECK (payment_method IN ('card','cash'))
);

ALTER TABLE public.transaction OWNER TO postgres;

CREATE TABLE public.go_board (x INT, y INT, color TEXT);

ALTER TABLE public.go_board OWNER TO postgres;

INSERT INTO public.country(country_id, name, continent, population_millions, gdp_usd_billions) VALUES
('IT','Italy','Europe',59.0,2100),
('FR','France','Europe',68.0,3000),
('JP','Japan','Asia',125.0,4200),
('EG','Egypt','Africa',110.0,400),
('US','United States','North America',333.0,27000);

INSERT INTO public.city(city_id, country_id, name, latitude, longitude, population_millions) VALUES
('C1','IT','Rome',     41.9028,  12.4964, 2.9),
('C2','FR','Paris',    48.8566,   2.3522, 2.1),
('C3','JP','Kyoto',    35.0116, 135.7681, 1.5),
('C4','EG','Giza',     29.9773,  31.1325, 4.0),
('C5','US','New York', 40.7128, -74.0060, 8.8);

INSERT INTO public.famoussite(site_id, city_id, name, category, unesco, year_established, latitude, longitude) VALUES
('S1','C1','Colosseum','historical',TRUE,   80,   41.8902,  12.4922),
('S2','C2','Eiffel Tower','landmark',FALSE,1889,  48.8584,   2.2945),
('S3','C3','Kiyomizu-dera','religious',TRUE, 778, 34.9949, 135.7850),
('S4','C4','Great Pyramid of Giza','historical',TRUE,-2560, 29.9792, 31.1342),
('S5','C5','Statue of Liberty','landmark',FALSE,1886, 40.6892, -74.0445);

INSERT INTO public.traveler(traveler_id, name, home_country_id, birth_date, segment) VALUES
('T1','Alex Kim','US',DATE '1998-05-12','student'),
('T2','Camille Dubois','FR',DATE '1985-03-21','family'),
('T3','Haru Sato','JP',DATE '2001-11-08','solo'),
('T4','Noor Hassan','EG',DATE '1992-07-30','business');

INSERT INTO public.trip(trip_id, traveler_id, start_date, end_date, purpose, budget_usd) VALUES
('TR1','T1',DATE '2025-06-01',DATE '2025-06-10','leisure',     1800),
('TR2','T2',DATE '2025-07-15',DATE '2025-07-22','family visit',2400),
('TR3','T3',DATE '2025-08-05',DATE '2025-08-14','sightseeing', 1600),
('TR4','T4',DATE '2025-05-10',DATE '2025-05-16','conference',  2100);

INSERT INTO public.sitevisit(trip_id, site_id, visit_date, minutes_spent, group_size, rating) VALUES
('TR1','S1',DATE '2025-06-03',180,1,5),
('TR1','S2',DATE '2025-06-07',120,2,4),
('TR2','S2',DATE '2025-07-18',150,4,5),
('TR3','S3',DATE '2025-08-08',200,1,5),
('TR4','S5',DATE '2025-05-12', 90,1,4),
('TR4','S3',DATE '2025-07-08',400,1,5),
('TR4','S3',DATE '2025-05-18',100,2,5),
('TR1','S1',DATE '2025-12-08',300,1,5),
('TR1','S3',DATE '2025-07-08',30,1,5),
('TR1','S4',DATE '2025-07-08',700,1,5),
('TR1','S1',DATE '2025-06-15',150,1,5);

INSERT INTO public.transaction(transaction_id, trip_id, site_id, date, type, amount_usd, payment_method) VALUES
('TX1','TR1','S1',DATE '2025-06-03','ticket',     25.00,'card'),
('TX2','TR1','S2',DATE '2025-06-07','souvenir',   30.00,'card'),
('TX3','TR2','S2',DATE '2025-07-18','ticket',     45.00,'cash'),
('TX4','TR3','S3',DATE '2025-08-08','food',       20.00,'card'),
('TX5','TR4','S5',DATE '2025-05-12','guided tour',50.00,'card'),
('TX6','TR2','S5',DATE '2025-05-12','guided tour',10.00,'card'),
('TX7','TR1','S5',DATE '2025-05-12','guided tour',20.00,'card');

INSERT INTO public.go_board VALUES
  (2, 1, 'W'),
  (1, 2, 'W'),
  (3, 2, 'W'),
  (2, 3, 'W'),
  (4, 3, 'B'),
  (3, 4, 'B'),
  (5, 4, 'B'),
  (4, 5, 'B');

--INSERT INTO public.souvenir (souvenir_id, amount_usd, site_id, traveler_id) VALUES
--('SV1', 25.00, 'S1', 'T1'),
--('SV2', 40.00, 'S2', 'T2'),
--('SV3', 15.50, 'S3', 'T3'),
--('SV4', 60.00, 'S5', 'T4'),
--('SV5', 18.00, 'S2', 'T1');

