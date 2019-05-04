create view vw_stops as
select distinct
    s.id as id,
    r.id as route_id,
    m.id as mobile_id,
    o.id as organisation_id,
    s.name as name,
    s.community as community,
    s.address as address,
    s.postcode as postcode,
    s.arrival as arrival,
    s.departure as departure,
    s.timetable as timetable
from stop s
join route r on s.route_id = r.id
join mobile m on m.id = r.mobile_id
join organisation o on m.organisation_id = o.id
order by o.id, m.id, r.id, s.id, s.name;