-- -- -- -- --
-- From PostgresSQL Bootcamp

create table directors (
  director_id SERIAL PRIMARY KEY,
	first_name varchar(150),
	last_name varchar(150) NOT NULL,
	nationality varchar(20),
	date_of_birth DATE,
	add_date DATE,
	update_date DATE
)


create if not exists table actors (
	actor_id SERIAL PRIMARY  KEY,
	first_name varchar(150),
	last_name varchar(150) NOT NULL,
	gender char(1),
	date_of_birth DATE,
	add_date DATE,
	update_date DATE
);

select * from directors;

--drop table movies;

create table movies (
	movie_id SERIAL PRIMARY KEY,
	movie_name VARCHAR(100) NOT NULL,
	movie_length INT, 
	movie_lang VARCHAR(20),
	age_certificate varchar(10),
	release_date DATE,
	director_id INT REFERENCES directors (director_id)
);

create table movies_revenues (
  revenue_id serial primary key,
  movie_id int references movies (movie_id),
  revenues_domestic numeric (10,2),
  revenues_international numeric (10,2)
);

select * from movies_revenues;

create table movies_actors (
 movie_id INT references movies (movie_id),
 actor_id INT references actors (actor_id),
 primary key (movie_id, actor_id)
);

select * from movies_actors;


create table customers (
 customer_id serial primary key,
 first_name varchar(50),
 last_name varchar(50),
 email varchar(150),
 age int
);


insert into customers (first_name,last_name,email,age) values('marjo','monni','asdf@asdf.fi',23);

insert into customers (first_name,last_name,email,age) 
values
('marjo1','monni','asdf@asdf.fi',21),
('marjo2','monni','asdf@asdf.fi',22),
('marjo3','monni','asdf@asdf.fi',23),
('marjo4','monni','asdf@asdf.fi',24);


insert into customers (first_name,last_name) values('Bill ''O','monni');

insert into customers (first_name) values ('ADAM1') returning customer_id;

update customers set email = 'a''f''f@asdf.com'
where customer_id = 1;

update customers set email = 'a''f''f@asdf.com', last_name='JeepulisJaska'
where customer_id = 1;

select * from customers;

update customers 
set 
email = 'a£b.com'
where customer_id = 3
returning *;

delete from customers where customer_id = 3;


create table t_tags(
id serial primary key,
tag text unique,
update_date timestamp default now()
);

insert into t_tags (tag) values
('Pen'),
('Pencil');

select * from t_tags;

-- 2023-05-24 14_40:24.361237

insert into t_tags (tag) 
values ('Pen') 
on conflict (tag)
do
 nothing;

insert into t_tags (tag) 
values ('Pen') 
on conflict (tag)
do
 update set
  tag = EXCLUDED.tag || NOW(),
  update_date = now();
 
select tag as "Column name with spaces" from t_tags
select tag "Column name with spaces" from t_tags

-- single quotes wont do
select tag 'Column name with spaces' from t_tags 
select tag 'Column' from t_tags;
 
select "Column name with spaces" from
(select tag as "Column name with spaces" from t_tags) as a1;

-- concat
select first_name || ' ' || last_name from actors; 

-- select with only exrpession
select 10 / 2 as tulos;

-- order by

select * from movies order by release_date asc;

select * from movies order by release_date;


select * from movies order by release_date desc;

select 
left(movie_name,1) as eka, movie_name,release_date
from movies
order by
eka asc,
release_date desc
;

select 
first_name,
last_name as surname
from actors
order by last_name desc;

select 
first_name,
length(first_name) as len
from actors 
order by
len desc;

select 
first_name,
length(first_name) as len
from actors 
order by
length(first_name) asc;

select 
first_name,
length(first_name) as len
from actors 
order by
(length(first_name) + 1 )asc;

select 
first_name, 
last_name,
date_of_birth
from actors
order by
first_name asc,
date_of_birth desc;

select 
first_name, 
last_name,
date_of_birth
from actors
order by
1 asc,
3 desc;

select 
first_name, 
last_name,
date_of_birth
from actors
order by
1 asc,
3 desc;

-- Howto handle NULL in sorting

create table demo_sorting
(
	num int
)

insert into demo_sorting (num)
values
(1),
(2),
(3),
(4),
(NULL)

select * from demo_sorting order by num asc;

select * from demo_sorting order by num asc nulls first;

drop table demo_sorting;

-- distinct

select movie_lang
from movies;

select 
distinct movie_lang
from movies order by 1;

select 
distinct director_id
from movies order by 1;

select 
distinct movie_lang, director_id
from movies order by 1;

---
-- operators

-- 1. comparison
-- =
-- <
-- <=
-- >
-- >=
-- <>

-- 2. logical
-- AND
-- OR
-- LIKE
-- IN
-- BETWEEN

-- +
-- -
-- /
-- *
-- %
