create or replace view vw_routes as
select
    r.id,
    la.id as local_authority_id,
    la.id as organisation_id,
    la.code as local_authority_code,
    la.code as service_code,
    m.id as mobile_id,
    r.name as name,
    r.frequency,
    r.timetable,
    r.start as start,
    r.end as end,
    count(distinct s.id) as number_stops
from route r
join mobile m on m.id = r.mobile_id
join local_authority la on m.local_authority_id = la.id
join route_stop rs on rs.route_id = r.id
join stop s on s.id = rs.stop_id
group by r.id, la.id, la.code, m.id, r.name, r.frequency, r.timetable, r.start, r.end;
