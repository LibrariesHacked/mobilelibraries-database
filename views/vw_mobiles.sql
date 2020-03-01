create view vw_mobiles as
select
    m.id as id,
    m.organisation_id,
    m.name as name,
    m.timetable,
    count(distinct r.id) as number_routes,
    count(distinct s.id) as number_stops
from mobile m
join route r on r.mobile_id = m.id
join route_stop rs on rs.route_id = r.id
join stop s on s.id = rs.stop_id
group by m.id, m.organisation_id, m.name, m.timetable;