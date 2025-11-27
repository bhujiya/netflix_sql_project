-- Netflix Project

create Table netflix(
					show_id varchar(6),
					type varchar(15),
					title varchar(250),
					director varchar(550),
					casts varchar(1050),
					country	varchar(550),
					date_added varchar(55),
					release_year int,
					rating varchar(15),
					duration varchar(15),
					listed_in varchar(250),
					description varchar(550)

);


-- 1. Count the Number of Movies vs TV Shows

select type, count(*) as total_content from netflix
group by 1;


-- 2. Find the Most Common Rating for Movies and TV Shows
select * from (
select type, rating, count(*),
rank() over(partition by type order by count(*)desc) as rnk from netflix
group by 1, 2

order by 1, 3 desc)
where rnk =1;


-- 3. List All Movies Released in a Specific Year (e.g., 2020)

select title from netflix
where release_year = 2020;

-- 4. Find the Top 5 Countries with the Most Content on Netflix
select * from netflix

select country, count(*) from(
select unnest(string_to_array(country, ',')) as country  from netflix) as t
where country is not null
group by 1
order by 2 desc
limit 5;

-- 5. Identify the Longest Movie

select title, duration from netflix
where type = 'Movie' and duration is not null
order by split_part(duration,' ', 1)::int desc;

-- 6. Find Content Added in the Last 5 Years

select title, date_added from netflix
where to_date(date_added, 'Month DD, YYYY')>=current_date-Interval '5 years';

-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

select * from(
select *, unnest(string_to_array(director,',')) as dir_name from netflix) as t
where dir_name = 'Rajiv Chilaka';

-- 8. List All TV Shows with More Than 5 Seasons
select title, duration from netflix
where type = 'TV Show' and split_part(duration,' ', 1)::int > 5;

-- 9. Count the Number of Content Items in Each Genre
select unnest(string_to_Array(listed_in,',')) as genre, count(*) from netflix
group by 1;

-- 10. Find each year and the average number of content releases in India on netflix.
with expand as(
select show_id, release_year, unnest(string_to_array(country,',')) as country1 from netflix
)

select release_year, country1, count(show_id),
round(count(show_id)::numeric/(select count(show_id) from expand
where country1 = 'India')::numeric *100, 2) as avg_release from expand
where country1 = 'India'
group by 1,2;

-- 11. List All Movies that are Documentaries
SELECT *, unnest(string_to_array(listed_in,',')) from netflix
where 'Documentaries' = any(string_to_array(listed_in,',')) and type = 'Movie';


--  12. Find All Content Without a Director
select * from netflix
where director is null;

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE)-10;

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
select unnest(string_to_array(casts,',')), count(show_id) from netflix
where country like '%India%'
group by 1
order by 2 desc
limit 10;

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
select category, count(*) as content_count from
(select case
		when description ilike '%kill%' or description ilike '%violence%' then 'Bad'
		else 'Good'
	end as category
	from netflix) as category_content
group by 1;