-- create database IMDB;
-- use IMDB;

-- SHOW tables;

use IMDB;

		-- ------------ Segment 1: Database - Tables, Columns, Relationships ------------------

-- ■ 1.What are the different tables in the database and how are they connected to each other in the database?

/*
-► There are 6 different tables in the database movie_project those are director_mapping, genre, movies, names, ratings, role_mapping.
   The tables are connected on movie_id and name_id with each other.
  */    
      
-- ■ 2.Find the total number of rows in each table of the schema.

SELECT table_name, table_rows 
from information_schema.tables 
WHERE table_schema = 'IMDB';

/*	
--------------------------------------
► Tables with the count of rows in it. 
--------------------------------------
	TABLE_NAME			TABLE_ROWS
	director_mapping	3867
	erd					28
	genre				14600
	movies				7788
	names				8323
	ratings				7948
	role_mapping		15845 */
-- ----------------------------------    



-- 3.Identify which columns in the movie table have null values.


/* ► NOTE : This was a tricky task as the database had many EMPTY STRINGS, hence counting NULL values was not working.
	 Assigning EMPTY STRINGS a NULL value was important for the data consistency and usability while analysing the data.
	 For doindg the same I used a META DATA Query to get the query for all the columns to upate the values at once.
	 I used the below query and it generated queries like this "UPDATE movies SET country = NULL WHERE country =''; " for all the columns at once. 
	 I made my task easier by automating the typing of query again and again for each column.
 */

SELECT CONCAT(
    'UPDATE movies SET ',
    COLUMN_NAME,
    ' = NULL WHERE ',
    COLUMN_NAME,
    ' =''''; '
) AS update_statement
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'IMDB' AND TABLE_NAME = 'movies';
/*
-----------------------------------------------------
The above query produced the below statements which we will run to assign EMPTY STRING a NULL vlaue
-----------------------------------------------------
*/

SET SQL_SAFE_UPDATES =0; 
UPDATE movies SET country = NULL WHERE country =''; 
UPDATE movies SET date_published = NULL WHERE date_published =''; 
UPDATE movies SET duration = NULL WHERE duration =''; 
UPDATE movies SET id = NULL WHERE id =''; 
UPDATE movies SET languages = NULL WHERE languages ='';
UPDATE movies SET production_company = NULL WHERE production_company =''; 
UPDATE movies SET title = NULL WHERE title =''; 
UPDATE movies SET worlwide_gross_income = NULL WHERE worlwide_gross_income =''; 
UPDATE movies SET year = NULL WHERE year =''; 

/* Below query provided with the count of the NULL values in columns of movies table.
*/

select sum(case when id is null then 1 else 0 end) as id_null,
    sum(case when title is null then 1 else 0 end) as title_null,
    sum(case when year is null then 1 else 0 end) as year_null,
    sum(case when date_published is null then 1 else 0 end) as date_null,
    sum(case when duration is null then 1 else 0 end) as duration_null,
    sum(case when country is null then 1 else 0 end) as country_null,
    sum(case when worlwide_gross_income is null or 0 then 1 else 0 end) as income_null,
    sum(case when languages is null then 1 else 0 end) as languages_null,
    sum(case when production_company is null then 1 else 0 end) as production_company_null from movies;


/* 	
---------------------------------------------------------------
► Columns with count of NULL values in it. 
+--------+------------+-----------+-----------+--------------+--------------+-------------+-----------------+-------------------------+
|id_null | title_null | year_null | date_null |duration_null | country_null | income_null |  languages_null | production_company_null |
|  0     |     0      |    0      |      0    |      0       |     20       |     3724    |       194       |           528           |
+--------+------------+-----------+-----------+--------------+--------------+-------------+-----------------+-------------------------+
 
 ► We have four columns with NULL values 
		 COLUMN NAME       Count of NULL values
		 1. country  			 20
		 2. income   			 3724
		 3. languages			 194
		 4. production_company 	 528
-- -----------------------------------------------------	
*/


                         -- --------- Segment 2: Movie Release Trends --------------


-- 	► 1. Determine the total number of movies released each year and analyse the month-wise trend.

SELECT year, count(*) as movies
 from movies
 group by year
 order by year ;

/* 
year	movies
2017	3052
2018	2944
2019	2001
*/

/* Month wise trend */

SELECT year, month(date_published) as month_no, count(*) as movies_count
 from movies
 group by year, month(date_published)
 order by year,month(date_published) ;

/*

year  month_no  movies_count
2017	1		291
2017	2		228
2017	3		298
2017	4		249
2017	5		205
2017	6		199
2017	7		115
2017	8		295
2017	9		195
2017	10		117
2017	11		282
2017	12		187
2018	1		203
2018	2		112
2018	3		269
2018	4		184
2018	5		111
2018	6		108
2018	7		106
2018	8		168
2018	9		104
2018	10		163
2018	11		184
2018	12		122
2019	1		142
2019	2		248
2019	3		152
2019	4		159
2019	5		186
2019	6		160
2019	7		152
2019	8		193
2019	9		162
2019	10		162
2019	11		173
2019	12		171
*/	

-- ------------------------------------------------------

/* ► 2. Calculate the number of movies produced in the USA or India in the year 2019.*/

SELECT count(*) as count_of_movies 
FROM movies
WHERE  year = '2019'
AND 
(country like '%India%' or
country like '%USA%');


/*	count_of_movies
		1059    */
        
        
				-- --------- Segment 3: Production Statistics and Genre Analysis --------------


/* ► 1. Retrieve the unique list of genres present in the dataset. */
SELECT * FROM genre;
SELECT DISTINCT genre FROM genre;
/* 
genre
Thriller
Fantasy
Drama
Comedy
Horror
Romance
Family
Adventure
Sci-Fi
Action
Mystery
Crime
Others   */ 
-- ----------------------------------------------------------------------------------


/* ► 2. Identify the genre with the highest number of movies produced overall. */ 

SELECT genre, count(*) AS count_genre 
from genre 
group by genre
order by count_genre DESC
LIMIT 1;

/*
genre   count_genre
Drama	4285  			 */

-- ---------------------------------------------------------------

/* ► 3. Determine the count of movies that belong to only one genre.  */ 

SELECT  count(movie_id)
FROM (
SELECT movie_id , count(distinct genre) as genre_count 
FROM genre
group by movie_id
) GC
where genre_count = 1 ; 

/*  
count(movie_id)
   3289          */
-- ---------------------------------------------------------------------------

/* ► 4. Calculate the average duration of movies in each genre.  */ 

with genre_cte as
(select a.*,b.genre from movies a
join genre b on a.id=b.movie_id)
select genre, avg(duration) as avg_duration 
from genre_cte
group by genre
order by avg_duration desc;

-- ------------------------------------------------------------

-- ► 5. Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced.

with genre_cte as(
select genre, count(movie_id) as movies
from genre
group by genre)
select * from
(select *,rank() over(order by movies desc) as m_rank
from genre_cte)t
where genre='Thriller'
;
   
			-- ------------- Segment 4: Ratings Analysis and Crew Members ----------------------

-- ► 1. Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).

select min(avg_rating) as minimum_avg_rating,
min(total_votes) as minimum_total_votes,
min(median_rating) as minimum_median_rating,
max(avg_rating) as maximum_avg_rating,
max(total_votes) as maximum_total_votes,
max(median_rating) as maximum_median_rating
from ratings;


-- ► 2. Identify the top 10 movies based on average rating.
with top_movies as
(select title, avg_rating,
dense_rank()over(order by avg_rating desc)as rk
from movies a
left join ratings b
on a.id=b.movie_id)
select* from top_movies
where rk<=10
order by rk;


-- ► 3. Summarise the ratings table based on movie counts by median ratings.
select count(movie_id) as movie_count, median_rating
from ratings
group by median_rating
order by movie_count desc;

-- ► 4. Identify the production house that has produced the most number of hit movies (average rating > 8).
select m.production_company, count(r.movie_id) as movies
from ratings r 
join movies m on r.movie_id=m.id
where r.avg_rating>8
group by production_company
order by movies desc;


-- ► 5. Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.

select genre, count(a.movie_id) as movie_count
from genre a join movies b on a. movie_id=b.id
join ratings c on a.movie_id=c.movie_id
where year=2017 and month(b.date_published)=3 and
b.country like '%USA%'and c.total_votes> 1000
group by a.genre
order by movie_count desc;

-- ► 6. Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.

with cte as
(select title,avg_rating, genre
from ratings a
join genre b on a.movie_id=b.movie_id
join movies c on b. movie_id= c.id
where title like'%The%' and avg_rating >8)
select title, avg_rating, group_concat(distinct genre) as genres
from cte group by title,avg_rating
order by title;
            
            -- ----------------------- Segment 5: Crew Analysis --------------------

-- ► 1. Identify the columns in the names table that have null values.

SELECT CONCAT(
    'UPDATE names SET ',
    COLUMN_NAME,
    ' = NULL WHERE ',
    COLUMN_NAME,
    ' =''''; '
) AS update_statement
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'IMDB' AND TABLE_NAME = 'names';

UPDATE names SET id = NULL WHERE id =''; 
UPDATE names SET name = NULL WHERE name =''; 
UPDATE names SET height = NULL WHERE height =''; 
UPDATE names SET date_of_birth = NULL WHERE date_of_birth =''; 
UPDATE names SET known_for_movies = NULL WHERE known_for_movies =''; 


select sum(case when id is null then 1 else 0 end) as id_null_count,
sum(case when name is null then 1 else 0 end) as name_null_count,
sum(case when height is null then 1 else 0 end) as height_null_count,
sum(case when date_of_birth is null then 1 else 0 end) as dob_null_count,
sum(case when known_for_movies is null then 1 else 0 end) as known_for_movies_null_count
from names;

-- ► 2. Determine the top three directors in the top three genres with movies having an average rating > 8.
with genre_top_3 as
(select genre, count(movie_id) as num_movies
from genre 
where movie_id in (select movie_id from ratings where avg_rating > 8)
group by genre
order by num_movies desc
limit 3) ,

director_genre_movies as
(select b.movie_id,b.genre,c.name_id,d.name
from genre b 
join director_mapping c
on b.movie_id = c.movie_id
join names d on c.name_id = d.id
where b.movie_id in (select movie_id from ratings where avg_rating > 8))

select * from
(select genre,name as director_name,count(movie_id) as num_movies,
row_number() over (partition by genre order by count(movie_id) desc) as director_rk
from director_genre_movies 
where genre in (select distinct genre from genre_top_3)
group by genre,name)t
where director_rk <= 3
order by genre,director_rk;

-- ► 3. Find the top two actors whose movies have a median rating >= 8.
with top_actors as
(select name_id,count(movie_id) as num_movies
from role_mapping 
where category = 'actor'
and movie_id in (select movie_id from ratings where median_Rating >= 8)
group by name_id
order by num_movies desc
limit 2)

select b.name as actors,num_movies 
from top_actors a
join names b
on a.name_id = b.id
order by num_movies desc;

--  ► 4. Identify the top three production houses based on the number of votes received by their movies.

select production_company,sum(total_votes) as totalvote
from movies a join ratings b on a.id = b.movie_id
group by production_company
order by totalvote desc
limit 3; 


-- ► 5.  Rank actors based on their average ratings in Indian movies released in India.
with actors_cte as
(select name_id,sum(total_votes) as total_votes,
count(a.movie_id) as movie_count,
sum(avg_rating * total_votes)/sum(total_votes) as actor_avg_rating
from role_mapping a
join ratings b
on a.movie_id = b.movie_id
where category = 'actor'
and a.movie_id in
(select distinct id from movies
where country like '%India%')
group by name_id)


select b.name as actor_name,total_votes,movie_count,actor_avg_rating,
dense_rank() over (order by actor_avg_rating desc) as actor_rank
from actors_cte a
join names b
on a.name_id = b.id
order by actor_avg_rating desc ;



-- ► 6.  Identify the top five actresses in Hindi movies released in India based on their average ratings.

with actors_cte as
(select name_id,sum(total_votes) as total_votes,
count(a.movie_id) as movie_count,
sum(avg_rating * total_votes)/sum(total_votes) as actress_avg_rating
from role_mapping a
join ratings b
on a.movie_id = b.movie_id
where category = 'actress'
and a.movie_id in
(select distinct id from movies
where country like '%India%'
and languages like '%Hindi%')
group by name_id)


select b.name as actor_name,total_votes,movie_count,round(actress_avg_rating,2) as actress_avg_rating,
dense_rank() over (order by actress_avg_rating desc,total_votes desc) as actress_rank
from actors_cte a
join names b
on a.name_id = b.id
-- where movie_count > 1
order by actress_rank ;

                     -- ------------- Segment 6: Broader Understanding of Data ----------------

-- ► 1.  Classify thriller movies based on average ratings into different categories.
select a.title,case when avg_Rating > 8 then '1. Superhit'
when avg_rating between 7 and 8 then '2. Hit'
when avg_rating between 5 and 7 then '3. One-time-watch'
else '4. Flop' end as movie_category
from movies a
join ratings b
on a.id = b.movie_id
where a.id in (select movie_id from genre where genre = 'Thriller')
order by movie_category;

-- ► 2. analyse the genre-wise running total and moving average of the average movie duration.

with genre_avg_duration as
(select genre, avg(duration) as avg_duration
from genre a join movies b
on a.movie_id = b.id
group by genre)

select genre ,round(avg_duration,2) avg_duration,
round(sum(avg_duration) over (order by genre),2) as running_total,
round(avg(avg_duration) over (order by genre),2) as moving_avg
from genre_avg_duration order by genre;


-- ► 3. Identify the five highest-grossing movies of each year that belong to the top three genres.
with genre_top_3 as
(select genre, count(movie_id) as movie_count
from genre group by genre
order by movie_count desc
limit 3),

base_table as
(select a.*,b.genre, replace(worlwide_gross_income,'$ ','') as new_gross_income
from movies a
join genre b
on a.id = b.movie_id
where genre in (select genre from genre_top_3))

select * from 
(select genre,year,title,worlwide_gross_income,
dense_rank() over (partition by genre,year order by new_gross_income desc) as movie_rank
from base_table)t
where movie_rank <= 5
order by genre,year,movie_rank;


-- ► 4. Determine the top two production houses that have produced the highest number of hits among multilingual movies.

select production_company,count(id) as movie_count
from movies
where locate(',',languages)>0
and id in (Select movie_id from ratings where avg_rating > 8)
and production_company is not null
group by production_company
order by movie_count desc
limit 2;

-- ► 5. Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.
with actors_cte as
(select name_id,sum(total_votes) as total_votes,
count(a.movie_id) as movie_count,
sum(avg_rating * total_votes)/sum(total_votes) as actress_avg_rating
from role_mapping a
join ratings b
on a.movie_id = b.movie_id
where category = 'actress'
and a.movie_id in
(select distinct movie_id from genre
where genre = 'Drama')
group by name_id
having sum(avg_rating * total_votes)/sum(total_votes) > 8)


select b.name as actor_name,total_votes,movie_count,round(actress_avg_rating,2) as actress_avg_rating,
dense_rank() over (order by actress_avg_rating desc,total_votes desc) as actress_rank
from actors_cte a
join names b
on a.name_id = b.id
-- where movie_count > 1
order by actress_rank 
limit 3;

-- ► 6. Retrieve details for the top nine directors based on the number of movies, including average inter-movie duration, ratings, and more.

with top_directors as
(Select name_id as director_id,count(movie_id) as movie_count
from director_mapping group by name_id
order by movie_count desc
limit 9),

movies_summary as
(select b.name_id as director_id,a.*,avg_rating,total_votes
from movies a join director_mapping b
on a.id = b.movie_id
left join ratings c
on a.id = c.movie_id
where b.name_id in (select director_id from top_directors)),

final as
(select *, lead(date_published) over (partition by director_id order by date_published) as nxt_movie_date,
datediff(lead(date_published) over (partition by director_id order by date_published),date_published) as days_gap
from movies_summary)

select director_id,b.name as director_name,
count(a.id) as movie_count,
round(avg(days_gap),0) as avg_inter_movie_duration,
round(sum(avg_rating*total_votes)/sum(total_votes),2) as avg_movie_ratings,
sum(Total_votes) as total_votes,
min(avg_rating) as min_rating,
max(avg_rating) as max_rating,
sum(duration) as total_duration
from final a
join names b
on a.director_id = b.id
group by director_id,name
order by avg_movie_ratings desc;



						-- ------------- Segment 7: Recommendations --------------------------
/*
 Based on the analysis, provide recommendations for the types of content Bolly movies should focus on producing.

 Genre recommentations :--1. Pay attention to genre that have a consistend track record of producing successfull movies over the years.
                            2. Comedy,drama, triller are the genre which has highet world wide income in last 3 years.
 
Actor and actress recommentation: --1. Sangeetha Bhat,Fatmire Sahiti,Pranati Rai Prakash are the actresss who has most number of rating in drama genre ,
                                     2.Consider collaborating with top actress who have excelled in the drama genre for hindi movies
                                    
Director recommentation: --1. Collaborate with directors who have a proven track record of directing movies with high average ratings. 
							 2.A.L.Vijay and Andrew Johnes are the top directors based on number of movies and Steven Soderbergh and Sam Liu are the directors who list minimum,highest and maximum rating.alter
                            
 release month recommentation: 1. Month of release also matters in the success of movies. Consider releasing movies during months with a track record of producing hits
 */ 
 
 
 
        