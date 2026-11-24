create or replace view vw_mobiles as
select
    m.id as id,
    m.local_authority_id,
    m.local_authority_id as organisation_id,
    la.code as local_authority_code,
    la.code as service_code,
    m.name as name,
    m.timetable,
    count(distinct r.id) as number_routes,
    count(distinct s.id) as number_stops
from mobile m
join route r on r.mobile_id = m.id
join route_stop rs on rs.route_id = r.id
join stop s on s.id = rs.stop_id
join local_authority la on la.id = m.local_authority_id
group by m.id, m.local_authority_id, la.code, m.name, m.timetable;
