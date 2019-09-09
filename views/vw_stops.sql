create view vw_stops as
with route_events as (
    select id as route_id, date_timestamp as date_timestamp from vw_routes_events
)
select distinct
    s.id as id,
    r.id as route_id,
    r.name as route_name,
    m.id as mobile_id,
    m.name as mobile_name,
    o.id as organisation_id,
    o.name as organisation_name,
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
	to_jsonb(array(select date_timestamp::date from (
        select date_timestamp from route_events where route_events.route_id = r.id
    ) as instances)) as route_dates,
	st_x(s.geom) as longitude,
	st_y(s.geom) as latitude
from stop s
join route r on s.route_id = r.id
join mobile m on m.id = r.mobile_id
join organisation o on m.organisation_id = o.id;