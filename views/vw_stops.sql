create or replace view vw_stops as
select
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
    s.type as type,
    s.exceptions as exceptions,
	r.frequency as route_frequency,
	to_json(array(
        select 
            route_date 
        from route_dates 
        where route_dates.route_id = r.id
        and not route_dates.route_date::text = ANY (coalesce(string_to_array(s.exceptions, ','), array[]::text[]))
        )
    ) as route_dates,
    s.geom as geom,
	st_x(s.geom) as longitude,
	st_y(s.geom) as latitude
from stop s
join route r on s.route_id = r.id
join mobile m on m.id = r.mobile_id
join organisation o on m.organisation_id = o.id;