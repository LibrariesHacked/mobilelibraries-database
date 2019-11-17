create view vw_stops as
with dates as (
    select 
        route_id, 
        route_date
    from route_dates
)
select distinct
    s.id as id,
    r.id as route_id,
    r.name as route_name,
    m.id as mobile_id,
    m.name as mobile_name,
    o.id as organisation_id,
    o.name as organisation_name,
    o.colour as organisation_colour,
    s.name as name,
    s.community as community,
    s.address as address,
    s.postcode as postcode,
    s.arrival as arrival,
    s.departure as departure,
    s.timetable as timetable,
    r.start as route_start,
    r.end as route_end,
	to_char(r.start, 'Day') as route_day,
	r.frequency as route_frequency,
	to_jsonb(array(select route_date from (
        select route_date from dates where dates.route_id = r.id
    ) as instances)) as route_dates,
    s.geom as geom,
	st_x(s.geom) as longitude,
	st_y(s.geom) as latitude
from stop s
join route r on s.route_id = r.id
join mobile m on m.id = r.mobile_id
join organisation o on m.organisation_id = o.id;