CREATE TABLE genres (
	name text UNIQUE,
	position integer
);

CREATE TABLE movies (
	movie_id SERIAL PRIMARY KEY,
	title text,
	genre cube
);

CREATE TABLE actors (
	actor_id SERIAL PRIMARY KEY,
	name text
);

CREATE TABLE movies_actors (
	movie_id integer REFERENCES movies NOT NULL,
	actor_id integer REFERENCES actors NOT NULL,
	UNIQUE ( movie_id, actor_id)
);

CREATE INDEX movies_actors_movie_id ON movies_actors(movie_id);
CREATE INDEX movies_actors_actor_id ON movies_actors (actor_id);
CREATE INDEX movies_genres_cube ON movies USING gist(genre);

SELECT title FROM movies WHERE title ILIKE 'stardust%';

SELECT title FROM movies WHERE title ILIKE 'stardust_%';

SELECT COUNT(*) FROM movies WHERE title !~* '^the.*';

-- 2
select count(*) from 
(select unnest(array['moi','hei']) as moi, unnest(array[1,NULL]) as luku ) q1;
-- 1
select count(luku) from 
(select unnest(array['moi','hei']) as moi, unnest(array[1,NULL]) as luku ) q1;

select levenshtein('bat', 'fads');

select 'fads' as alku, 
		levenshtein('bat', 'fads') fads,
		levenshtein('bat', 'fad') fad,
		levenshtein('bat', 'fat') fat,
		levenshtein('bat', 'bat') bat,
		'bat' loppu;
		
select movie_id, title FROM movies
WHERE levenshtein(lower(title), lower('a hard day night')) <= 3;

select show_trgm('Avatar');

CREATE INDEX movies_title_trigram ON movies
USING gist(title gist_trgm_ops);

SELECT title
FROM movies
WHERE title % 'Avatre';

SELECT title
FROM movies
WHERE title @@ 'night & day';

-- normalisointi
SELECT title
FROM movies 
WHERE to_tsvector(title) @@ to_tsquery('english', 'night & day');

SELECT *
FROM movies
WHERE title @@ to_tsquery('english', 'a');

SELECT to_tsvector('english', 'A Hard Day''s Night');

SELECT to_tsvector('finnish','Janne joutui vankilaan');

select to_tsvector('finnish','vankila'),to_tsvector('finnish','vankilassa'),to_tsvector('finnish','vankilaan');

select 'Janne joutui vankilaan' as teksti 

select ts_lexize('english_stem', 'Day''s');

select to_tsvector('german', 'was machst du gerade?');

EXPLAIN 
SELECT *
FROM movies 
WHERE title @@ 'night & day';

EXPLAIN 
SELECT *
FROM movies 
WHERE to_tsvector('english',title) @@ 'night & day';

select * from actors
where name = 'Broos Wils'

select * from actors
where name % 'Broos Wils'

select * from movies
select * from movies_actors
select * from actors

select * 
from movies NATURAL JOIN movies_actors NATURAL JOIN actors

select title 
from movies NATURAL JOIN movies_actors NATURAL JOIN actors
WHERE metaphone(name,6) = metaphone('Broos Wils', 6);

select distinct(name)--,title 
from movies NATURAL JOIN movies_actors NATURAL JOIN actors
WHERE metaphone(name,6) = metaphone('Broos Wils', 6);

select name, dmetaphone(name), dmetaphone_alt(name),metaphone(name,8),soundex(name) from actors;

SELECT 	name, 
		dmetaphone(name), 
		dmetaphone_alt(name),
		metaphone(name,8),
		soundex(name),
		metaphone('Robin Williams',8) gold_8,
		metaphone('Robin Williams',7) gold_7,
		metaphone('Robin Williams',6) gold_6,
		metaphone('Robin Williams',5) gold_5,
		metaphone('Robin Williams',4) gold_4,
		metaphone('Robin Williams',3) gold_3 
from actors
WHERE metaphone(name,8) % metaphone('Robin Williams',8)
ORDER BY levenshtein(lower('Robin Williams'), lower(name));

SELECT *
FROM actors, dmetaphone('Ron')
WHERE dmetaphone(name) % dmetaphone('Ron');

SELECT name,
      cube_ur_coord('(0,7,0,0,0,0,0,0,0,7,0,0,0,0,10,0,0,0)', position) as score
FROM genres g
WHERE cube_ur_coord('(0,7,0,0,0,0,0,0,0,7,0,0,0,0,10,0,0,0)', position) > 0;

SELECT *, 
	   cube_distance(genre, '(0,7,0,0,0,0,0,0,0,7,0,0,0,0,10,0,0,0)') dist
FROM movies
ORDER BY dist;

select * from genres

SELECT *, 
	   cube_distance(genre, '(0,7,0,0,0,0,0,0,0,7,0,0,0,0,10,0,0,0)') dist
FROM movies
ORDER BY dist;

SELECT * FROM movies

select cube(array[0,0],array[1,1])

select cube(array[-1,-1],array[1,1])
select cube(array[1,1])

select cube_enlarge('(1,2)',1,0)

select cube_enlarge('(1,2)',1,2)

select cube_enlarge('(0,7,0,0,0,0,0,0,0,7,0,0,0,0,10,0,0,0)'::cube, 5, 18);

select * from movies

select title,
		genre, 
		cube_distance(genre,'(0,7,0,0,0,0,0,0,0,7,0,0,0,0,10,0,0,0)') dist,
		cube_enlarge('(0,7,0,0,0,0,0,0,0,7,0,0,0,0,10,0,0,0)'::cube, 5, 18) en_cube,
		cube_enlarge('(0,7,0,0,0,0,0,0,0,7,0,0,0,0,10,0,0,0)'::cube, 5, 18) @> genre as totuus
from movies 
--where cube_enlarge('(0,7,0,0,0,0,0,0,0,7,0,0,0,0,10,0,0,0)'::cube, 5, 18) @> genre
order by dist;

select title, cube_distance(genre,'(0,7,0,0,0,0,0,0,0,7,0,0,0,0,10,0,0,0)') dist
from movies 
where cube_enlarge('(0,7,0,0,0,0,0,0,0,7,0,0,0,0,10,0,0,0)'::cube, 5, 18) @> genre
order by dist;

select cube_enlarge('(0,7,0,0,0,0,0,0,0,7,0,0,0,0,10,0,0,0)'::cube, 5, 18)

SELECT  m.movie_id, m.title, s.title, s.genre
FROM movies m, (SELECT genre, title FROM movies WHERE title = 'Mad Max') s
WHERE cube_enlarge(s.genre, 5,18) @> m.genre AND s.title <> m.title
ORDER BY cube_distance(m.genre, s.genre)
LIMIT 10;

SELECT cube_enlarge(cube(array[1,1,1], array[2,2,2]), 1, 3);

SELECT cube(array[1,1,1], array[2,2,2])
SELECT cube(array[1,1,1], array[1,1,1])

SELECT cube_enlarge(cube(array[1,1,1], array[2,2,2]), 1, 3);

SELECT cube_enlarge('(1,1,1)', 1, 3);

-- homework

DROP FUNCTION suosittelija(text)

CREATE OR REPLACE FUNCTION suosittelija(movie_name text) RETURNS text AS $$
DECLARE
	tulos text;
BEGIN
SELECT title INTO TULOS 
FROM
(SELECT m.title,m.genre,s.genre, s.title verrattu_title, s.isokuutio, cube_distance(m.genre,s.genre) dist 
	FROM movies m, (SELECT title, genre,cube_enlarge( genre, 6, 18 ) as isokuutio FROM movies WHERE 
--					title = movie_name--
				   title = 'Halloween'
				   ) as s
	WHERE isokuutio @> m.genre
	ORDER BY dist
	LIMIT 5) s1;
--	INTO tulos
	RETURN tulos;
END;
$$ LANGUAGE plpgsql	

select suosittelija('Halloween')

DROP FUNCTION suosittelija(text)

CREATE OR REPLACE FUNCTION suosittelija(movie_name text) RETURNS SETOF text AS $$
BEGIN
RETURN QUERY 
SELECT title FROM
(SELECT m.title,m.genre,s.genre, s.title verrattu_title, s.isokuutio, cube_distance(m.genre,s.genre) dist 
	FROM movies m, (SELECT title, genre,cube_enlarge( genre, 6, 18 ) as isokuutio FROM movies WHERE 
					title = movie_name--
--				   title = 'Halloween'
				   ) as s
	WHERE isokuutio @> m.genre
	ORDER BY dist
	LIMIT 5) s1;
--	INTO tulos
END;
$$ LANGUAGE plpgsql	

select suosittelija('Halloween')

DROP FUNCTION suosittelija(text)

CREATE OR REPLACE FUNCTION suosittelija(movie_name text, actor_name text) RETURNS SETOF text AS $$
BEGIN
	IF actor_name IS NULL THEN
		RETURN QUERY 
		SELECT title FROM
		(SELECT m.title,m.genre,s.genre, s.title verrattu_title, s.isokuutio, cube_distance(m.genre,s.genre) dist 
			FROM movies m, (SELECT title, genre,cube_enlarge( genre, 6, 18 ) as isokuutio FROM movies WHERE 
							title = movie_name--
		--				   title = 'Halloween'
						   ) as s
			WHERE isokuutio @> m.genre
			ORDER BY dist
			LIMIT 5) s1;
		--	INTO tulos
	ELSE
		RETURN QUERY
		SELECT title,name FROM movies NATURAL JOIN actors;
	END IF;
END;
$$ LANGUAGE plpgsql	

select * FROM movies NATURAL JOIN movies_actors--actors;

select suosittelija(NULL,'Bruce Willis')


CREATE FUNCTION multiply_by_two(input INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN input * 2;
END;
$$ LANGUAGE plpgsql;


































































