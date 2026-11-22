create or replace view vw_stops as
select
    s.id as id,
    array_agg(distinct r.id) as route_ids,
    array_agg(distinct r.name) as route_names,
    array_agg(distinct m.id) as mobile_ids,
    array_agg(distinct m.name) as mobile_names,
    o.id as organisation_id,
    o.name as organisation_name,
    o.colour as organisation_colour,
    o.code as service_code,
    o.code as local_authority_code,
    s.name as name,
    s.community as community,
    s.address as address,
    s.postcode as postcode,
    array_agg(distinct rs.arrival order by rs.arrival) as arrival_times,
    array_agg(distinct rs.departure order by rs.departure) as departure_times,
    s.timetable as timetable,
    min(r.start) as route_start,
    max(r.end) as route_end,
	array_agg(distinct to_char(r.start, 'FMDay')) as route_days,
    s.type as type,
    rs.exceptions as exceptions,
	array_agg(distinct r.frequency) as route_frequencies,
	array_agg(distinct sc.visit + rs.arrival order by sc.visit + rs.arrival) filter (where sc.visit is not null) as route_schedule,
    s.geom as geom,
	st_x(s.geom) as longitude,
	st_y(s.geom) as latitude
from stop s
join route_stop rs on rs.stop_id = s.id
join route r on rs.route_id = r.id
left join route_schedule sc on sc.route_id = r.id and not sc.visit::text = ANY (coalesce(rs.exceptions, array[]::text[]))
join mobile m on m.id = r.mobile_id
join organisation o on m.organisation_id = o.id
group by s.id, o.id, o.name, o.colour, o.code, s.name, s.community, s.address, s.postcode, s.type, s.timetable, rs.exceptions, s.geom;
