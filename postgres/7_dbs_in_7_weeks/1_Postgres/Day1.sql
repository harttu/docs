-- Week 1 - PostgresQL
-- Day 1

-- Luodaan taulu, huomaa char vs varchar
CREATE TABLE countries (
	country_code char(2) primary key,
	country_name text unique
);
-- Lisätäään tauluun
INSERT INTO countries(country_code, country_name)
VALUES ('us','United States'),
('gb','The United Kindom'),('mx','Mexico'),('au','Australia'),('de','Germany'),('ll','Loomlaland');

-- voidaan lisätä myös char jonka pituus 1
INSERT INTO countries(country_code, country_name)
VALUES ('f','Finland');

select * from countries;
delete from countries where country_code = 'll';
delete from countries where country_code = 'f';

CREATE TABLE cities (
	name text NOT NULL,
	postal_code varchar(9) CHECK (postal_code <> ''),
	country_code char(2) REFERENCES countries,
	PRIMARY KEY (country_code,postal_code)
)

INSERT INTO cities VALUES ('Toronto','M4B5C1','ca');
INSERT INTO cities VALUES ('Portland','2700','us');

UPDATE cities
SET postal_code = '97205'
WHERE name = 'Portland';

select * from cities

select cities.*, country_name
FROM cities INNER JOIN countries
ON cities.country_code = countries.country_code;

CREATE TABLE venues (
	venue_id SERIAL PRIMARY KEY,
	name varchar(255),
	street_address text,
	type varchar(7) CHECK (type in ('public','private')) DEFAULT 'public',
	postal_code varchar(9),
	country_code char(2),
	FOREIGN KEY (country_code,postal_code)
	REFERENCES cities(country_code,postal_code) MATCH FULL
);

INSERT INTO
venues(name,postal_code,country_code)
VALUES
('Ballroom','97205','us');

INSERT INTO venues (name, postal_code,country_code)
VALUES ('Voodoo Donuts','97205','us') RETURNING venue_id;

select * from venues;
select * from countries;

SELECT v.venue_id, v.name, c.name
FROM venues v INNER JOIN cities c
  ON v.postal_code=c.postal_code 
  AND v.country_code = c.country_code;

CREATE TABLE events (
event_id SERIAL,
venue_id integer,
title text,
starts timestamp,
ends timestamp,
PRIMARY KEY (event_id),
FOREIGN KEY (venue_id) REFERENCES venues(venue_id)
);

INSERT INTO
events(title,starts,ends,venue_id)
VALUES
('LARP Club','2012-02-15 17:30:00','2012-02-15 19:30:00',2);

INSERT INTO
events(title,starts,ends)
VALUES
('April Fools Day','2012-04-01 00:00:00','2012-04-01 23:59:00'),
('Christmas Day','2012-12-25 00:00:00','2012-12-25 23:59:00');

SELECT * FROM events;

SELECT e.title, v.name
FROM events e JOIN venues v
 ON e.venue_id = v.venue_id;
 
SELECT e.title, v.name
FROM events e JOIN venues v
USING (venue_id);

SELECT e.title, v.name
FROM events e LEFT JOIN venues v
USING (venue_id);

SELECT e.title, v.name
FROM events e RIGHT JOIN venues v
USING (venue_id);

SELECT e.title, v.name
FROM events e FULL JOIN venues v
USING (venue_id);

-- luodaan indexi
CREATE INDEX events_title ON events USING hash(title);

-- Using btree, >=, = , > can be used
SELECT * FROM events WHERE starts >= '2012-04-01';

CREATE INDEX events_starts 
ON events USING btree(starts);

-- CRUD Create, Read, Update, Delete
-- SQL Structured Query Language


-- Kotitehtävät s.21 - tehtävä 3

-- MATCH FULL
--A value inserted into the referencing column(s) is matched against the values of the referenced table and referenced 
--columns using the given match type. There are three match types: MATCH FULL, MATCH PARTIAL, and MATCH SIMPLE 
--(which is the default). 
--MATCH FULL will not allow one column of a multicolumn foreign key to be null unless all 
--foreign key columns are null; if they are all null, the row is not required to have a match in the referenced table. 
--MATCH SIMPLE allows any of the foreign key columns to be null; 
--if any of them are null, the row is not required to have a match in the referenced table. 
--MATCH PARTIAL is not yet implemented. (Of course, NOT NULL constraints can be applied to the referencing column(s)
--to prevent these cases from arising.)

drop table if exists slave_match_full;
drop table if exists slave_match_simple;
drop table if exists master;

CREATE TABLE master(
id serial primary key,
second_id integer,
third_id integer,
unique(second_id,third_id)
);

insert into master(second_id,third_id) 
values (1,1),(1,2),(1,NULL);

insert into master(second_id,third_id) 
values (1,NULL);

select * from master;

CREATE TABLE slave_match_full(
id serial primary key,
second_id integer,
third_id integer,	
FOREIGN KEY(second_id,third_id) 
REFERENCES master(second_id,third_id) MATCH FULL);

CREATE TABLE slave_match_simple(
id serial primary key,
second_id integer,
third_id integer,	
FOREIGN KEY(second_id,third_id) 
REFERENCES master(second_id,third_id) MATCH SIMPLE);

select * from master;

-- tämä ei mene läpi
insert into slave_match_full(second_id) values (1);
insert into slave_match_full(second_id) values (NULL);
select * from slave_match_full;

-- tämä menee läpi
insert into slave_match_simple(second_id) values (1);
insert into slave_match_simple(second_id) values (NULL);

select * from slave_match_full;
select * from slave_match_simple;

-- tehtävä 4:
select * from pg_class where relnamespace = '2200' and reltype <> 0;
-- tehtävä 5:
SELECT * FROM events e JOIN venues v USING(venue_id)
JOIN countries co ON v.country_code = co.country_code;
-- sama kuin
SELECT country_name as "Country Name" FROM events e JOIN venues v USING(venue_id)
JOIN countries co using(country_code)
where title='LARP Club';
--tehtävä 6:
alter table venues
add active boolean default true;

select * from venues;


-- Day 2
select * from countries;

insert into countries(country_code, country_name) 
values ('fi','Finland');

select * from cities;

insert into cities(name,postal_code, country_code) 
values ('Åbo','20000','fi');

select * from venues;

insert into venues(name,postal_code,country_code)
values ('My Place','20000','fi');

select * from venues;

insert into events (title, starts, ends, venue_id)
values('Moby','2012-02-06 21:00', '2012-02-06 23:00', (
SELECT venue_id FROM venues WHERE name = 'Crystal Ballroom')
);

update events
set venue_id = (
SELECT venue_id FROM venues WHERE name = 'Ballroom')
where event_id = 4 
returning venue_id;

select * from events;

insert into events (title, starts, ends, venue_id)
values('Wedding','2012-02-26 21:00', '2012-02-26 23:00', (
SELECT venue_id FROM venues WHERE name = 'Voodoo Donuts')
);

select * from events;

insert into events (title, starts, ends, venue_id)
values
('Dinner with Mom','2012-02-26 18:00', '2012-02-26 20:30', (
SELECT venue_id FROM venues WHERE name = 'My Place')),
 ('Valentine''s Day','2012-02-14 00:00', '2012-02-14 23:59', NULL);

insert into events (title, starts, ends, venue_id)
values
 ('Valentine''s Day','2012-02-14 00:00', '2012-02-14 23:59', NULL);

delete from events where event_id = 8;

select * from events;
select * from venues;

select title,starts,ends,name as venue from events e left join venues v using(venue_id);
