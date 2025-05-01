SELECT * FROM netflix;

SELECT COUNT (*) as TOTAL_CONTENT
FROM netflix;

SELECT DISTINCT type FROM netflix;

-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems

-- 1. Count the number of Movies vs TV Shows

SELECT type, COUNT(*)
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS
(SELECT
       rating,
	   type,
	   COUNT(*) as rating_count
       FROM netflix
       GROUP BY rating,type),
 Ranked_rating AS
	(SELECT 
	       rating, 
		   type, 
		   rating_count,
		   RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) as rank
	     FROM RatingCounts)
SELECT 
    type,
    rating AS most_frequent_rating
FROM Ranked_Rating
WHERE rank = 1;
	   
-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * FROM netflix
WHERE release_year = 2020 AND type = 'Movie';

-- 4. Find the top 5 countries with the most content on Netflix

SELECT 
TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS COUNTRY_RELEASE,
COUNT(show_id)
FROM netflix
GROUP BY COUNTRY_RELEASE
ORDER BY COUNT(show_id) DESC,COUNTRY_RELEASE
LIMIT 5;

--5. Identify the longest movie

SELECT title, 
       CAST(REPLACE(duration, 'min', ' ' ) AS INTEGER)
	   AS duration_minutes
FROM netflix
where type = 'Movie'
and duration IS NOT NULL
ORDER BY duration_minutes DESC
LIMIT 1;

--6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

WITH MOVIE_DIRECTOR AS
(SELECT type,
        title,  
		TRIM(UNNEST(STRING_TO_ARRAY(director,','))) as DIRECTOR_NAME
FROM netflix )
SELECT type,
        title,  
		DIRECTOR_NAME
		FROM MOVIE_DIRECTOR
		WHERE DIRECTOR_NAME = 'Rajiv Chilaka';

		--or--

SELECT * 
FROM
(
SELECT
     *, 
     UNNEST(STRING_TO_ARRAY(director,',')) as DIRECTOR_NAME
	 FROM 
	 netflix
	 )
	 WHERE DIRECTOR_NAME = 'Rajiv Chilaka'

-- 8. List all TV shows with more than 5 seasons	 

SELECT type,title, duration
FROM netflix
WHERE TRIM(type) = 'TV Show'
AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5 

-- 9. Count the number of content items in each genre

SELECT 
      DISTINCT(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS GENRE,
	  COUNT(*) AS TOTAL_CONTENT
FROM netflix
GROUP BY GENRE
ORDER BY 2 DESC,1;

-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !


SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5


-- 11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries'



-- 12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.



SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2




-- End of reports









