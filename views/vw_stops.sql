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
    rs.arrival as arrival,
    rs.departure as departure,
    s.timetable as timetable,
    r.start as route_start,
    r.end as route_end,
	to_char(r.start, 'Day') as route_day,
    s.type as type,
    s.exceptions as exceptions,
	r.frequency as route_frequency,
	to_json(array(
        select 
            visit 
        from route_schedule
        where route_schedule.route_id = r.id
        and not route_schedule.visit::text = ANY (coalesce(string_to_array(s.exceptions, ','), array[]::text[]))
        )
    ) as route_schedule,
    s.geom as geom,
	st_x(s.geom) as longitude,
	st_y(s.geom) as latitude
from stop s
join route_stop rs on rs.stop_id = s.id
join route r on rs.route_id = r.id
join mobile m on m.id = r.mobile_id
join organisation o on m.organisation_id = o.id;