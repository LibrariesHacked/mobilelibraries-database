create or replace view vw_stops_timetable as
select
     s.id,
     s.name,
     m.id as mobile_id,
     r.id as route_id,
     rstop.day,
     (rs.visit + rstop.arrival) as arrival,
     (rs.visit + rstop.departure) as departure
from stop s
join route_stop rstop on rstop.stop_id = s.id
join route r on r.id = rstop.route_id
join mobile m on m.id = r.mobile_id
join route_schedule rs on rs.route_id = r.id
    and extract(isodow from rs.visit)::integer = case rstop.day
        when 'Monday' then 1
        when 'Tuesday' then 2
        when 'Wednesday' then 3
        when 'Thursday' then 4
        when 'Friday' then 5
        when 'Saturday' then 6
        when 'Sunday' then 7
    end
where not rs.visit::text = ANY (coalesce(rstop.exceptions, array[]::text[]));
