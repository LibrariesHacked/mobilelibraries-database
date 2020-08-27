create or replace view vw_stops_timetable as
with stops as (
     select
          s.id,
          s.name,
          m.id as mobile_id,
          r.id as route_id,
          rs.arrival,
          rs.departure,
          rs.exceptions
     from stop s
     join route_stop rs on rs.stop_id = s.id
     join route r on r.id = rs.route_id
     join mobile m on r.mobile_id = m.id
)
select
     stops.id,
     stops.name,
     stops.mobile_id,
     stops.route_id,
     (rs.visit + stops.arrival) as arrival,
     (rs.visit + stops.departure) as departure
from stops
left join route_schedule rs on rs.route_id = stops.route_id
where not rs.visit::text = ANY (coalesce(stops.exceptions, array[]::text[]));