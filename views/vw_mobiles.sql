create view vw_mobiles as
select distinct
    m.id as id,
    m.name as mobile_name,
    m.timetable as mobile_timetable,
    o.id as organisation_id,
    o.name as organisation_name,
    o.timetable as organisation_timetable,
    count(distinct r.id) as number_routes,
    count(distinct s.id) as number_stops
from mobile m
join organisation o on m.organisation_id = o.id
join route r on r.mobile_id = m.id
join stop s on s.route_id = r.id
group by m.id, m.name, o.id, o.name, o.timetable
order by m.id, m.name, o.id, o.name, o.timetable;