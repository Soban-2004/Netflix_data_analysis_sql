DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);

SELECT * FROM netflix;

SELECT COUNT(*) FROM netflix;



--1. Count the number of Movies vs TV Shows
select 
	type,
	count(*) as total
from netflix
group by 1;


--2. Find the most common rating for movies and TV shows

Select type,rating
from(
select 
	type,
	rating,
	count(*),
	rank() over(partition by type order by count(*) desc) as ranking
from netflix
group by 1,2
) as t1
where ranking = 1;


--3. List all movies released in a specific year (e.g., 2020)

select * from netflix
where type = 'Movie'
and release_year = 2020



--4. Find the top 5 countries with the most content on Netflix


select
	trim(unnest(STRING_TO_ARRAY(country,','))) as new_country,
	count(*)
	
from netflix
group by 1
order by 2 desc
limit 5;


--5. Identify the longest movie

select 
	title,
	SPLIT_PART(duration,' ',1)::numeric as duration
from netflix
where 
	type = 'Movie' 
	and 
	duration is not null
order by 2 desc
limit 1



--6. Find content added in the last 5 years

select
	distinct(title),
	TO_DATE(date_added,'Month DD, YYYY') as date
from netflix
where 
TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'
order by 2 desc


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!


select 
* from netflix
where director ilike '%rajiv chilaka%'




--8. List all TV shows with more than 5 seasons

select 
	title,
	type,
	duration
from netflix
where type = 'TV Show'
and SPLIT_PART(duration,' ',1)::numeric>5


--9. Count the number of content items in each genre

select 
	trim(unnest(STRING_TO_ARRAY(listed_in,','))) as genre,
	count(*)
from netflix
group by 1


--10.Find each year and the average numbers of content release in India on netflix.



select 	
	extract(year from TO_DATE(date_added,'Month DD, YYYY')) as date,
	count(*),
	round(
	count(*)::numeric/(select count(*) from netflix where country ilike '%India%')::numeric * 100
	,2)as avg_content
from netflix
where country ilike '%India%'
group by 1
order by 1 desc


--11.List all movies that are documentaries

select title,listed_in
from netflix
where listed_in ilike '%documentaries%'
and type <> 'TV Show'


--12. Find all content without a director

select *
from netflix
where director is null


--13.Find how many movies actor 'Salman Khan' appeared in last 10 years!

select release_year,title,casts
from netflix
where casts ilike '%Salman khan%'
and
release_year >= extract(year from (CURRENT_DATE - INTERVAL '10 years')):: INT
order by release_year asc



--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
	trim(unnest(string_to_array(casts,','))) as actors,
	count(*) as Movie_Count
from netflix
where country ilike '%India%'
and type = 'Movie'
group by 1
order by 2 desc
limit 10


/*15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/

with new_table as (
select 
	title,
	description,
	case 
	when description ilike '% kill%'
		or description ilike '% violence%'
		then 'Bad Content'
		else 'Good Content'
	end as category
from netflix
)

select category,count(*)
from new_table
group by 1







