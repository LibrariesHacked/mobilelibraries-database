create view vw_routes as
select
    r.id as id,
    o.id as organisation_id,
    m.id as mobile_id,
    r.name as name,
    r.frequency as frequency,
    r.timetable as timetable,
    r.start as start,
    r.end as end,
    count(distinct s.id) as number_stops
from route r
join mobile m on m.id = r.mobile_id
join organisation o on m.organisation_id = o.id
join stop s on s.route_id = r.id
group by r.id, o.id, m.id, r.name, r.frequency, r.timetable;