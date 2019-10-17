create view vw_stops_timetable as
with stops as (
     select
          s.id,
          m.id as mobile_id,
          r.id as route_id,
          s.arrival,
          s.departure,
          r.frequency
     from stop s
     join route r on r.id = s.route_id
     join mobile m on r.mobile_id = m.id
)
select
     stops.id,
     stops.mobile_id,
     stops.route_id,
     stops.arrival,
     stops.departure,
     (re.date_timestamp::date + stops.arrival) as arrival,
     (re.date_timestamp::date + stops.departure) as departure
from stops
join vw_routes_events re
on re.id = stops.route_id;