create or replace view vw_stops_timetable as
with stops as (
     select
          s.id,
          s.name,
          m.id as mobile_id,
          r.id as route_id,
          rs.arrival,
          rs.departure,
          s.exceptions
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
     (rd.visit + stops.arrival) as arrival,
     (rd.visit + stops.departure) as departure
from stops
left join route_schedule rd on rd.route_id = stops.route_id
where not rd.visit::text = ANY (coalesce(string_to_array(stops.exceptions, ','), array[]::text[]));