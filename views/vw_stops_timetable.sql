create view vw_stops_timetable as
with stops as (
     select
          s.id, 
          m.id as mobile_id,
          r.id as route_id,
          r.start, 
          s.arrival,
          s.departure,
          coalesce(r.end, ((now() at time zone 'Europe/London') + interval '1 year')) as end, 
          ('FREQ=' || r.frequency ) as frequency
     from stop s 
     join route r on r.id = s.route_id
     join mobile m on r.mobile_id = m.id
)
select
     sd.id as id,
     sd.mobile_id,
     sd.route_id,
     (sd.date_timestamp::date + sd.arrival) as arrival,
     (sd.date_timestamp::date + sd.departure) as departure
from
     (select 
          stops.id,
          stops.mobile_id, 
          stops.route_id,
          stops.arrival, 
          stops.departure,
          rrule_event_instances_range(
               stops.start,
               stops.frequency, 
               (now() at time zone 'Europe/London')::date,
               stops.end,
               30
          ) as date_timestamp
     from stops) sd;