create view vw_routes as
select
    r.id,
    o.id as organisation_id,
    o.code as service_code,
    m.id as mobile_id,
    r.name as name,
    r.frequency,
    r.timetable,
    r.start as start,
    r.end as end,
    count(distinct s.id) as number_stops
from route r
join mobile m on m.id = r.mobile_id
join organisation o on m.organisation_id = o.id
join route_stop rs on rs.route_id = r.id
join stop s on s.id = rs.stop_id
group by r.id, o.id, o.code, m.id, r.name, r.frequency, r.timetable, r.start, r.end;