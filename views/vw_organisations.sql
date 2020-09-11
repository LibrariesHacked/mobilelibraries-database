create view vw_organisations as
select
    o.id,
    c.name as country,
    o.code as service_code,
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
join country c on c.id = o.country_id
join mobile m on m.organisation_id = o.id
join route r on r.mobile_id = m.id
join route_stop rs on rs.route_id = r.id
join stop s on rs.stop_id = s.id
group by o.id, c.name, o.code, o.name, o.timetable, o.website, o.email, o.colour, o.logo;