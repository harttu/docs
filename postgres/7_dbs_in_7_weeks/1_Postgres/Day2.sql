select * from events;

select count(title)
from events
where title like '%Day%';

select min(starts),max(ends)
from events inner join venues
on events.venue_id = venues.venue_id
where venues.name = 'Ballroom';

select *
from events inner join venues
using(venue_id);

select min(starts),max(ends)
from events inner join venues
using(venue_id)
where venues.name = 'Ballroom';

select min(starts),max(ends)
from events inner join venues
using(venue_id)
where name = 'Ballroom';

select * from events;

select venue_id from events where venue_id = 1;

--select venue_id, count(*) from events where venue_id = 1;
select 'moi', count(*) from events where venue_id = 1;
-- jos aggregaaattifunktion kanssa käyttää muita sarakenimi,
-- niin niiden pitää olla osa group_by:ta
--select venue_id, count(*) from events where venue_id = 1;

select count(*) from events where venue_id = 2;
select count(*) from events where venue_id = 3;
select count(*) from events where venue_id = 4;
select count(*) from events where venue_id is NULL;

-- toimii, mutta ei ole järkeä
select venue_id--, count(*) 
from events
group by venue_id;

select venue_id, count(*) 
from events
group by venue_id;

select * from events;

select venue_id
from events
group by venue_id
-- wheren tilalla voidaan käyttää having
having count(*) >= 2 and venue_id is not null;

-- eli jotta selectissä voidaan käyttää saraketta,
-- pitää se joko olla group by:ssä
-- tai sitten sitä pitää aggregaattifunktionsisällä
select venue_id,title
from events
group by venue_id,title
-- wheren tilalla voidaan käyttää having
having count(*) >= 1 and venue_id is not null and title = 'Wedding';

select venue_id,title
from events
group by venue_id,title
-- wheren tilalla voidaan käyttää having
having count(*) >= 1 and venue_id is not null and title = 'Wedding';

select venue_id from events group by venue_id;

select distinct venue_id from events;

-- ikkunafunktio on muuten sama kuin group by
-- mutta 'välitulokset' säilytetään
select venue_id, count(*)
over (partition by venue_id)
from events
order by venue_id;

-- ikkunafunktion kanssa voi siis käytää 
-- sarakkeita, eli 
-- ikään kuin pidetään taulu koskemattomana,
-- mutta sille voidaan laskea aggregaatteja
select venue_id,title, count(*)
over (partition by venue_id)
from events;

-- transactions
begin transaction;
delete from events;
select * from events;
rollback;
select * from events;

CREATE OR REPLACE FUNCTION add_event(title text, 
									 starts timestamp,
									 ends timestamp, 
									 venue text, 
									 postal varchar(9), 
									 country char(2))
RETURNS boolean AS $$
DECLARE 
did_insert boolean := false;
found_count integer;
the_venue_id integer;
BEGIN
 -- yritetään hakea venue
 SELECT venue_id INTO the_venue_id
 FROM venues v
 WHERE v.postal_code=postal AND 
       v.country_code=country AND 
	   v.name ILIKE venue
 LIMIT 1;

 -- jos sitä ei ole, niin lisätään se
 IF the_venue_id IS NULL THEN
  INSERT INTO venues (name, postal_code, country_code)
  VALUES (venue, postal,country)
  RETURNING venue_id INTO the_venue_id;
  -- merkataan muuttujaan, että tämä tehtiin	
  did_insert := true;
 END IF;

 -- Not: not an "error", as in some programming languages
 RAISE NOTICE 'Venue found %', the_venue_id;

 INSERT INTO events(title,starts,ends,venue_id)
 VALUES (title, starts, ends, the_venue_id);

 RETURN did_insert;
END;
$$ LANGUAGE plpgsql;

SELECT add_event('House Party',
				 '2012-05-03 23:00',
				 '2012-05-04 02:00',
				 'Run''s House',
				 '97205',
				 'us');

DROP TABLE IF EXISTS logs;

CREATE TABLE logs (
event_id integer,
old_title varchar(255),
old_starts timestamp,
old_ends timestamp,
--new_starts timestamp,
new_ends timestamp,
logged_at timestamp default current_timestamp);

CREATE OR REPLACE FUNCTION log_event() 
RETURNS TRIGGER AS $$
DECLARE
BEGIN
INSERT INTO logs(event_id,
				 old_title,
				 old_starts,
				 old_ends,
	--			 new_starts,
				 new_ends)
VALUES (OLD.event_id, 
		OLD.title,
		OLD.starts, 
		OLD.ends,
--	    NEW.starts,
	    NEW.ends);
RAISE NOTICE 'Someone just changed event #%', OLD.event_id;
return NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER log_events
  AFTER UPDATE ON events
  FOR EACH ROW EXECUTE PROCEDURE log_event();
  
UPDATE events
SET ends='2022-05-04 01:00:00'
WHERE title='House Party';

select * from logs;

CREATE VIEW holidays AS
  SELECT event_id AS holiday_id, title AS name, starts AS dae
  FROM events
  WHERE  title LIKE '%Day%' AND venue_id IS NULL;

select * from holidays;

alter table holidays
rename column dae to date;

select name, to_char(date, 'Month DD, Day, YYYY') AS date
FROM holidays
WHERE date <= '2012-04-01';
 
alter table events
add colors text array;

SELECT * FROM events;

CREATE OR REPLACE VIEW holidays AS 
 SELECT event_id AS holiday_id, title AS name, starts AS date , colors
 FROM events
 WHERE title LIKE '%Day%' AND venue_id IS NULL;
 
SELECT * FROM holidays;

UPDATE holidays SET colors= '{"red","green"}' WHERE name = 'Christmas Day';

SELECT * FROM holidays;

EXPLAIN VERBOSE
  SELECT *
  FROM holidays;
  
EXPLAIN 
  SELECT *
  FROM holidays;

EXPLAIN VERBOSE
 SELECT event_id AS holiday_id, title AS name, starts AS date , colors
 FROM events
 WHERE title LIKE '%Day%' AND venue_id IS NULL;


explain verbose
select count(*) from events where venue_id is not null group by venue_id ; 

explain analyze
select count(*) from events where venue_id is not null group by venue_id ; 

CREATE RULE update_holidays AS ON UPDATE TO holidays DO INSTEAD
		UPDATE events
		SET title 	= NEW.name,
			starts 	= NEW.date,
			colors 	= NEW.colors
		WHERE title = OLD.name;
		
UPDATE holidays SET colors = '{"red","green"}' WHERE name = 'Christmas Day';

select * from events;

--explain verbose
SELECT NOW(),NOW() + interval '1 week';

INSERT INTO events(venue_id,title,starts,ends) VALUES (1,'TestiINSERT',NOW(),NOW()+interval '1 week');

select * from events;

CREATE OR REPLACE RULE insert_holidays AS ON INSERT TO holidays DO INSTEAD
		INSERT INTO events(title,starts)
		VALUES ( --NEW.holiday_id,
				 NEW.name,
			     NEW.date
			--colors 	= NEW.colors
				);		

select * from holidays;

insert into holidays(name,date) values ('Poop-fest Day',NOW()+ interval '1 week');

select * from holidays;
select * from events;

CREATE RULE delete_holidays AS ON DELETE TO holidays DO INSTEAD
	delete from events where events.event_id = OLD.holiday_id;
	
delete from holidays where holiday_id = 14;

select * from holidays;
select * from events;

select extract(year from starts) as year,
	   extract(month from starts) as month, 
	   count(*)
FROM events
GROUP BY year, month
ORDER BY year, month;

drop table month_count;

CREATE TEMPORARY TABLE month_count(month INT);

-- jompi kumpi
INSERT INTO month_count select generate_series(1,12);
INSERT INTO month_count VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12);

select * from month_count;

select * from generate_series(1,10);

CREATE EXTENSION tablefunc;

-- crosstab haluaa taulun muodossa rowid, category ja value
SELECT * FROM crosstab(
'SELECT extract(year from starts) as year,
		extract(month from starts) as month, 
		count(*)
 FROM events
 GROUP BY year, month
 ORDER BY year, month') AS (
 year int, 
	 jan int, feb int, mar int, apr int, may int, jun int, jul int, aug int, sep int, oct int, nov int, dec int
 ) ORDER BY YEAR;
 
 SELECT * FROM pg_extension WHERE extname = 'tablefunc';
 
 -- tämä ei toimi suoraan näin
 SELECT * FROM crosstab(
'SELECT extract(year from starts) as year,
        extract(month from starts) as month, 
        count(*)
 FROM events
 GROUP BY year, month
 ORDER BY year, month') 
AS ct("year" text, "Jan" int, "Feb" int, "Mar" int, "Apr" int, "May" int, "Jun" int, "Jul" int, "Aug" int, "Sep" int, "Oct" int, "Nov" int, "Dec" int);

 -- tämä ei toimi suoraan näin
SELECT * FROM crosstab(
'SELECT extract(year from starts) as year,
        extract(month from starts) as month, 
        count(*)
 FROM events
 GROUP BY year, month
 ORDER BY year, month',
 'SELECT * FROM month_count') 
AS ct("year" text, "Jan" int, "Feb" int, "Mar" int, "Apr" int, "May" int, "Jun" int, "Jul" int, "Aug" int, "Sep" int, "Oct" int, "Nov" int, "Dec" int);

SELECT extract(year from starts) as year,
        extract(month from starts) as month, 
        count(*)
 FROM events
 GROUP BY year, month
 ORDER BY year, month;

SELECT * FROM crosstab(
'SELECT extract(year from starts) as year,
        extract(month from starts) as month, 
        count(*)
 FROM events
 GROUP BY year, month
 ORDER BY year, month',
'SELECT generate_series(1,12)') 
AS ct("year" numeric, "Jan" bigint, "Feb" bigint, "Mar" bigint, "Apr" bigint, "May" bigint, "Jun" bigint, "Jul" bigint, "Aug" bigint, "Sep" bigint, "Oct" bigint, "Nov" bigint, "Dec" bigint);


CREATE TABLE test_bitwise (
    id serial primary key,
    bit_value int
);

INSERT INTO test_bitwise (bit_value) VALUES (6), (7), (5);
SELECT * FROM test_bitwise;
SELECT bit_and(bit_value) FROM test_bitwise;

CREATE TEMPORARY TABLE bitwise_testi(luku int);
INSERT INTO bitwise_testi VALUES (1),(0),(1),(0);
select bit_and(luku) FROM bitwise_testi;
select bit_or(luku) FROM bitwise_testi;

CREATE TEMPORARY TABLE bitwise_testi_bool(luku bool);
INSERT INTO bitwise_testi_bool VALUES (TRUE),(FALSE),(FALSE),(TRUE);
select bit_and(luku::int) FROM bitwise_testi_bool;
select bit_or(luku::int) FROM bitwise_testi_bool;

SELECT rolname, rolpassword FROM pg_authid;

SELECT * FROM venues;

CREATE RULE delete_venue AS ON DELETE TO venues DO INSTEAD
	UPDATE  venues
		SET
			active = FALSE
	WHERE venues.venue_id = OLD.venue_id;	
	
DROP RULE delete_venue ON venues;

SELECT * FROM venues;

DELETE FROM venues WHERE venue_id = 2;


SELECT extract(year from starts) as year,
        extract(month from starts) as month, 
        count(*)
 FROM events
 GROUP BY year, month
 ORDER BY year, month
 

create temporary table aika as SELECT '2023-01-01'::timestamp + interval '1 day' * s as aika FROM generate_series(0,364) as s;
select * from aika;

select extract(month from aika) kuukausi, extract(day from aika) paiva, to_char(aika,'Day') viikonpaiva from aika;

select * from
	crosstab('select extract(month from aika), extract(day from aika), to_char(aika,''Day'') from aika;',
			'SELECT generate_series(1,31)') as ct("Kuukausi" numeric,  
"day1" text, 
"day2" text, 
"day3" text, 
"day4" text, 
"day5" text, 
"day6" text, 
"day7" text, 
"day8" text, 
"day9" text, 
"day10" text, 
"day11" text, 
"day12" text, 
"day13" text, 
"day14" text, 
"day15" text, 
"day16" text, 
"day17" text, 
"day18" text, 
"day19" text, 
"day20" text, 
"day21" text, 
"day22" text, 
"day23" text, 
"day24" text, 
"day25" text, 
"day26" text, 
"day27" text, 
"day28" text, 
"day29" text, 
"day30" text, 
"day31" text
);


 SELECT *
FROM crosstab('select extract(month from aika), extract(day from aika), to_char(aika,''Day'') from aika;',
'SELECT generate_series(1,31)') AS ct("Kuukausi" numeric,  
"day1" text, 
"day2" text, 
"day3" text, 
"day4" text, 
"day5" text, 
"day6" text, 
"day7" text, 
"day8" text, 
"day9" text, 
"day10" text, 
"day11" text, 
"day12" text, 
"day13" text, 
"day14" text, 
"day15" text, 
"day16" text, 
"day17" text, 
"day18" text, 
"day19" text, 
"day20" text, 
"day21" text, 
"day22" text, 
"day23" text, 
"day24" text, 
"day25" text, 
"day26" text, 
"day27" text, 
"day28" text, 
"day29" text, 
"day30" text, 
"day31" text
);

-- tämä on haluttu kysely
select to_char(starts,'Week') as viikko,
	   to_char(starts,'D') as paiva,
	   count(*)
from events 
where trim(to_char(starts,'Month')) = 'February'
group by viikko,paiva
order by viikko,paiva asc;

SELECT * FROM crosstab(
'select to_char(starts,''Week'') as viikko,
	   to_char(starts,''D'') as paiva,
	   count(*)
from events 
where trim(to_char(starts,''Month'')) = ''February''
group by viikko,paiva
order by viikko,paiva asc;',
	'SELECT generate_series(1,7)') as ct(Viikko text, 
								  Sunday bigint, 
								  Monday bigint,
								 Tuesday bigint,
								 Wednesday bigint,
								 Thursday bigint,
								 Friday bigint,
								 Saturday bigint)
								 
								 
SELECT * FROM pg_extension;

CREATE EXTENSION IF NOT EXISTS tablefunc;
CREATE EXTENSION IF NOT EXISTS dict_xsyn;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS cube;

