SELECT * 
	FROM netflix.netflix_titles_cast
    where show_id in (
		select show_id 
        from netflix_titles_countries
        where country='United States'
    );
    
-- Data title where country is germany and cast where country is USA

With ti_country as(
select nt.title,nc.cast
	from netflix_titles nt
    inner join netflix_titles_cast nc
    on nt.show_id=nc.show_id
    where nt.show_id in (
		select show_id
        from netflix_titles_countries
        where country='spain'
	)
),
cast_country as (
	SELECT nt.title,nc.cast
	FROM netflix_titles_cast nc
    inner join netflix_titles nt    
    on nt.show_id=nc.show_id
    where nt.show_id in (
		select show_id 
        from netflix_titles_countries
        where country='United States'
    )
),
c as(
	select * from ti_country
    union all
    select * from cast_country    
)
,
d as(
	select * from ti_country
    union
    select * from cast_country    
),
duplicate_d as (
	select title,cast, count(*)
    from combine_all
    group by 1,2
    having count(*)>1
)
select * from duplicate_d

