create or replace view vw_stops_timetable as
with stops as (
     select
          s.id,
          s.name,
          m.id as mobile_id,
          r.id as route_id,
          s.arrival,
          s.departure,
          s.exceptions
     from stop s
     join route r on r.id = s.route_id
     join mobile m on r.mobile_id = m.id
)
select
     stops.id,
     stops.name,
     stops.mobile_id,
     stops.route_id,
     (rd.route_date + stops.arrival) as arrival,
     (rd.route_date + stops.departure) as departure
from stops
left join route_dates rd
on rd.route_id = stops.route_id
where not rd.route_date::text = ANY (coalesce(string_to_array(stops.exceptions, ','), array[]::text[]));