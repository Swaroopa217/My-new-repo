DROP TABLE IF EXISTS OLYMPICS_HISTORY;
select * from OLYMPICS_HISTORY
select * from OLYMPICS_HISTORY_NOC_REGIONS


CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY
(
    id          INT,
    name        VARCHAR(10),
    sex         VARCHAR(10),
    age         VARCHAR(10),
    height      VARCHAR(10),
    weight      VARCHAR(10),
    team        VARCHAR(10),
    noc         VARCHAR(10),
    games       VARCHAR(10),
    year        INT,
    season      VARCHAR(10),
    city        VARCHAR(10),
    sport       VARCHAR(10),
    event       VARCHAR(10),
    medal       VARCHAR(10)
);

DROP TABLE IF EXISTS OLYMPICS_HISTORY_NOC_REGIONS;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY_NOC_REGIONS
(
    noc         VARCHAR(10),
    region      VARCHAR(10),
    notes       VARCHAR(10)
);

-- 1. How many olympics games have been held?
select distinct games 
from olympics_history


select count(1) from olympics_history
select  count(*) from olympics_history_noc_regions

-- 2. list down the olympics games held so far
select distinct oh.year,oh.season,oh.city, OH.GAMES
    from olympics_history oh
    order by year;

-- 3. Mention the total no of nations who participated in each olympics game?
select * from olympics_history_noc_regions
select * from olympics_history    
    
    select games, count(nr.region)
    from olympics_history oh 
    join olympics_history_noc_regions nr on oh.noc = nr.noc
    group by games
    order by games


    with all_countries as
        (select games, nr.region
        from olympics_history oh
        join olympics_history_noc_regions nr ON nr.noc = oh.noc
        group by games, nr.region)
    select games, count(1) as total_countries
    from all_countries
    group by games
    order by games;

-- 4. Which year saw the highest and lowest no of countries participating in olympics

select * from olympics_history_noc_regions
select * from olympics_history    
with t1 as
(select oh.year, games, count(nr.region) as count_regions
    from olympics_history oh 
    join olympics_history_noc_regions nr on oh.noc = nr.noc
    group by games, year
    order by games)
select  min(count_regions) as lowest_count, max(count_regions) as highest_count
from t1 

-- 5. Which nation has participated in all of the olympic games
with tot_games as
(select count(distinct games) as total_no_of_games
from olympics_history),
     countries as
     ( select games , nr.region as country
	   from olympics_history oh
       join olympics_history_noc_regions nr on oh.noc = nr.noc
       group by games),
       countries_participated as
       ( select country, count(*) as total_participated_games
         from countries 
         group by country)
select cp*
from countries_participated as cp
inner join  tot_games tg on tg.total_no_of_games = cp.total_participated_games


select * from olympics_history_noc_regions
select * from olympics_history 

select city , count(*) as total_participated_games
from olympics_history oh
join olympics_history_noc_regions nr on oh.noc = nr.noc
group by city
order by city

--- 6. Identify the sport which was played in all summer olympics.
select * 
select sport, count(*) as no_of_games
from olympics_history
where season = 'summer'
group by sport
order by no_of_games
 
--- 7. Which Sports were just played only once in the olympics.
select * from olympics_history_noc_regions
select * from olympics_history 

select * 
from
(select sport, games,
count(sport) over(partition by sport) as no_of_games
from olympics_history
) as x
where x.no_of_games = 1
order by no_of_games desc
-- 8. Fetch the total no of sports played in each olympic games.
select * from olympics_history_noc_regions
select * from olympics_history 

select * from
select distinct games, count(sport) as total_no_of_sports
from olympics_history as x
group by distinct games
order by total_no_of_sports desc

SELECT DISTINCT games, COUNT(sport) AS total_no_of_sports
FROM olympics_history
GROUP BY games
ORDER BY total_no_of_sports DESC;




with t1 as
      	(select distinct games, sport
      	from olympics_history),
        t2 as
      	(select games, count(1) as no_of_sports
      	from t1
      	group by games)
      select * from t2
      order by no_of_sports desc;
-- 9. Fetch oldest athletes to win a gold medal



select *
from olympics_history
where medal = 'Gold'
order by games asc







   with temp as
            (select name,sex,cast(case when age = 'NA' then '0' else age end as int) as age
              ,team,games,city,sport, event, medal
            from olympics_history),
        ranking as
            (select *, rank() over(order by age desc) as rnk
            from temp
            where medal='Gold')
    select *
    from ranking
    where rnk = 1;
with t1 as
(select sex, count(*) as cnt 
from olympics_history 
group by sex),
     t2 as 
     (select *,
     row_number() over(order by cnt desc) as rn 
     from t1),
     min_count as
     ( select cnt from t2
       where rn = 1
     ),
     max_count as
     ( select cnt from t2
       where rn = 2
     )
-- 10. Find the Ratio of male and female athletes participated in all olympic games.
select x.* ,
row_number() over(order by cnt desc) as rn
from
(select count(*) as cnt, sex
from olympics_history
group by sex) as x
where rn = 1

select * 
from(
SELECT x.* ,
       row_number() OVER (ORDER BY cnt DESC) AS rn
FROM (
    SELECT COUNT(*) AS cnt, sex
    FROM olympics_history
    GROUP BY sex
) AS x
) as result
WHERE rn = 1 
-- 11. Fetch the top 5 athletes who have won the most gold medals.
select * from olympics_history

select * from
(select x.*,
row_number() over (order by cnt  desc) as rn
from
(select name,  count(*) AS CNT
from olympics_history 
where MEDAL = 'gold'
group by name) as x
) as result
where rn <= 5

-- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

select * from
(select x.*,
dense_rank() over (order by cnt  desc) as rn
from
(select name,  count(*) AS CNT
from olympics_history 
where medal in ('Gold', 'silver','bronze')
group by name) as x
) as result
where rn <= 5


 with t1 as
            (select name, team, count(1) as total_medals
            from olympics_history
            where medal in ('Gold', 'Silver', 'Bronze')
            group by name, team
            order by total_medals desc),
        t2 as
            (select *, dense_rank() over (order by total_medals desc) as rnk
            from t1)
    select name, team, total_medals
    from t2
    where rnk <= 5;
-- 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

select * from
(select x.*,
dense_rank() over( order by total_number_of_medals desc) as rnk
from(
select count(medal) as total_number_of_medals, nr.region
from olympics_history oh
join olympics_history_noc_regions nr on oh.noc = nr.noc
where medal <> 'NA'
group by nr.region) as x
) as result
where rnk <= 5;


-- 14. List down total gold, silver and bronze medals won by each country.

SELECT
    oh.country,
    COALESCE(SUM(medal = 'Gold'), 0) AS gold,
    COALESCE(SUM(medal = 'Silver'), 0) AS silver,
    COALESCE(SUM(medal = 'Bronze'), 0) AS bronze
FROM
    (
        SELECT
            nr.region AS country,
            oh.medal
        FROM olympics_history oh
        JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
        WHERE medal IN ('Gold', 'Silver', 'Bronze')
    
    ) AS oh
GROUP BY oh.country
ORDER BY gold DESC, silver DESC, bronze DESC;

-- 14. List down total gold, silver and bronze medals won by each country.
select x.country,
            COALESCE(SUM(medal = 'Gold'), 0) AS gold,
            COALESCE(SUM(medal = 'Silver'), 0) AS silver,
            COALESCE(SUM(medal = 'Bronze'), 0) AS bronze
from
(select nr.region as country,
        oh.medal
from olympics_history oh
join olympics_history_noc_regions nr on oh.noc = nr.noc
where medal in ('gold', 'silver', 'bronze')
) as x
group by x.country
order BY gold DESC, silver DESC, bronze DESC;

-- 15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
select x.country, x.games,
            COALESCE(SUM(medal = 'Gold'), 0) AS gold,
            COALESCE(SUM(medal = 'Silver'), 0) AS silver,
            COALESCE(SUM(medal = 'Bronze'), 0) AS bronze
from
(select nr.region as country,
        oh.medal, games
from olympics_history oh
join olympics_history_noc_regions nr on oh.noc = nr.noc
where medal in ('gold', 'silver', 'bronze')
) as x
group by x.country, x.games
order BY gold DESC, silver DESC, bronze DESC;

select * from olympics_history

-- 18. Which countries have never won gold medal but have won silver/bronze medals?

select *
from (select x.country,
            COALESCE(SUM(medal = 'Gold'), 0) AS gold,
            COALESCE(SUM(medal = 'Silver'), 0) AS silver,
            COALESCE(SUM(medal = 'Bronze'), 0) AS bronze
from
(select nr.region as country,
        oh.medal
from olympics_history oh
join olympics_history_noc_regions nr on oh.noc = nr.noc
where medal in ('gold', 'silver', 'bronze')
) as x
group by x.country
order BY gold DESC, silver DESC, bronze DESC
) as y
where y.gold = 0 and y.silver > 0 and y.bronze > 0

-- 19. In which Sport/event, India has won highest medals.
select * from
(select sport, nr.region, count(medal) as cnt
from olympics_history oh 
join  olympics_history_noc_regions nr on oh.noc = nr.noc
where medal <> 'NA'
group by sport, nr.region
order by cnt desc) as x
where x.region = 'India' 
limit 1

  20. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games

SELECT nr.region, games , sport, count(*) as total_medals
FROM olympics_history oh
join olympics_history_noc_regions nr on oh.noc = nr.noc
where medal <> 'NA' and team = 'INDIA' AND SPORT = 'hOCKEY'
group by nr.region, games ,sport


  select team, sport, games, count(1) as total_medals
    from olympics_history
    where medal <> 'NA'
    and team = 'India' and sport = 'Hockey'
    group by team, sport, games
    order by total_medals desc;



