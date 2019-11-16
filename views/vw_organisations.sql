create view vw_organisations as
select
    o.id,
    o.code,
    o.name,
    o.timetable,
    o.website,
    o.email,
    o.colour,
    o.logo,
    count(distinct m.id) as number_mobiles,
    count(distinct r.id) as number_routes,
    count(distinct s.id) as number_stops
from organisation o 
join mobile m on m.organisation_id = o.id
join route r on r.mobile_id = m.id
join stop s on s.route_id = r.id
group by o.id, o.name, o.timetable;