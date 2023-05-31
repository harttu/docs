select * from movies;

select * from movies 
where
movie_lang = 'English';

select * from movies 
where
	movie_lang = 'Japanese';

select * from movies 
where
	movie_lang = 'Japanese';

select * from movies 
where
movie_lang = 'English'
and age_certificate = '18';

select * from movies 
where
	movie_lang = 'Japanese'
	or movie_lang = 'Chinese'
order by movie_lang;

select * from movies 
where movie_lang = 'English';

select * from movies 
where
	( movie_lang = 'English'
	or movie_lang = 'Chinese' )
	and age_certificate = '12'
order by movie_lang;

select * from movies
where
movie_lang = 'English';

-- 10 can we use aliases in where clases?
select first_name, 
	last_name as surname
from actors
where
last_name = 'Allen'; -- wont work
--surname = 'Allen'; -- wont work

-- 11. What is the order of execution of where clauses
select *
from movies
where movie_lang = 'English'
order by
movie_length desc;

--
--12 

--a
select * from movies
where movie_length > 100
order by movie_length;

--b
select * from movies
where movie_length >= 100
order by movie_length;

--c
select * from movies
where movie_length <= 100
order by movie_length;

select * from movies
order by release_date asc;

-- with dates use quotes
select * from movies where
release_date > '2000-12-31';

-- wer
select * from movies
where 
movie_lang <= 'Ez'
order by movie_lang;

-- 9

select * from movies
where 
movie_lang <> 'English'
order by movie_lang;

-- 10 Can we omit quotes when ysung numerical values
select * from movies
where movie_length > '100';
-- same as
select *
from movies where movie_length > 100;

-- 1 .Get the top 5 biggest movie zby movie length
select * from movies order by movie_name;

select * from movies
order by movie_name desc
limit 5;

-- 2. get the top 5 oldest american directors
select * 
from directors
order by date_of_birth asc;

select * 
from directors
where 
nationality = 'American'
order by date_of_birth asc
limit 5;

-- 3. select the top 10 youngest female actors
select 
*
from actors
where
gender = 'F'
order by date_of_birth desc;

-- 4. Get the top 10 most domestic profitables movies
select 
*
from movies_revenues
order by revenues_domestic desc nulls last -- nulls last here
limit 10;

-- 4. Get the top 10 most domestic profitables movies
select 
*
from movies_revenues
order by revenues_domestic asc nulls last -- nulls last here
limit 10;

select 
*
from movies
order by movie_id -- nulls last here
limit 5 offset 1;

select 
*
from
movies_revenues
order by revenues_domestic desc nulls last
limit 5 offset 5;


-- using FETCH

-- fetch {first | next } [ row_count ] { ROW | ROWS } only
select 
* 
from movies
fetch first 1 row only;

select * from movies
order by movie_length desc
fetch first 5 row only


select *
from directors
order by date_of_birth asc
fetch first 2 rows only;


-- get the top 10 youngest female actors
select *
from actors 
where 
gender = 'F'
order by date_of_birth desc
fetch first 10 row only

-- select first 5 movies from the 5 th record onwards by long movie length
select 
*
from movies
order by movie_length desc
fetch first 5 row only
offset 5

-- same as
select 
*
from movies
order by movie_length desc
offset 5
fetch first 5 row only

--
-- IN
select 
*
from movies
where
movie_lang='English'
or movie_lang='Chinese'
or movie_lang='Japanese'
order by movie_lang;
--same as
select 
*
from movies
where
movie_lang in ('English','Chinese','Japanese')
order by movie_lang;


select * from movies
where age_certificate IN ('12','PG')
order by age_certificate asc

select * from movies
where director_id not in ('13','10')
order by director_id

-- for numerical data, 
select * from movies
where director_id not in (13,10)
order by director_id

-- 4 get all actors where actor_id is not 1,2,3,4
select * 
from actors
where actor_id not in (1,2,3,4)
order by actor_id


-- 
--- BETWEEN and NOT BETWEEN
select 
* 
from actors
where date_of_birth between '1991-01-21' and '1995-09-27' -- including at both ends
order by date_of_birth desc nulls last

select * from movies
where release_date between '1998-01-01' and '2002-12-31'
order by release_date

-- for integers
--290.30, 102.10
select * from movies_revenues
where revenues_domestic between 102.10 and 290.30
order by revenues_domestic

select * from movies
where movie_length not between 100 and 200
order by movie_length

select * from movies
where movie_length >= 100 and movie_length <= 200
order by movie_length


--
-- LIKE
select 'hello' like 'hello';

select 'hello' like 'h%';

select 'hello' like '%e%'

select 'hello' like 'Hell%'
select 'hello' ilike 'Hell%'

select 'hello' like 'hell_' -- underscore for one any character

select 'HELLO' ilike 'hell_' -- underscore for one any character

select 'hello' like '%ll_';  -- true

select 'hello' like '%ll__'; -- false

select 'hello','hi' like '%e%'

-- 6. Get all actors names where first name starting with 'A'
select * from actors
where first_name like 'A%'
order by first_name;

-- get 
select * from actors 
where first_name like '_____'
order by first_name

select * from actors 
where first_name ilike '[ab]%'
order by first_name


-- null
select *
from actors 
where date_of_birth is null or first_name is null
order by date_of_birth


-- 3. Get list of movies where domestic revenues is null
select 
* 
from movies_revenues
order by revenues_domestic;

select 
* 
from movies_revenues
where revenues_domestic is null
order by revenues_domestic;

-- 4. Get 
select 
*
from movies_revenues
where 
	revenues_domestic is null
	or
	revenues_international is null
	
	
-- 5. Get list of movies where either domes
select 
*
from movies_revenues
where revenues_domestic is not null

-- 6
select
*
from actors 
order by date_of_birth nulls first

select
*
from actors 
where date_of_birth = NULL

select
*
from actors 
where date_of_birth = 'NULL'

-- this is the right way
select
*
from actors 
where date_of_birth is NULL
