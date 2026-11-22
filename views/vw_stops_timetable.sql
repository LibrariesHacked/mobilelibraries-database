create or replace view vw_stops_timetable as
select
     s.id,
     s.name,
     m.id as mobile_id,
     r.id as route_id,
     (rs.visit + rstop.arrival) as arrival,
     (rs.visit + rstop.departure) as departure
from stop s
join route_stop rstop on rstop.stop_id = s.id
join route r on r.id = rstop.route_id
join mobile m on m.id = r.mobile_id
join route_schedule rs on rs.route_id = r.id
where not rs.visit::text = ANY (coalesce(rstop.exceptions, array[]::text[]));
