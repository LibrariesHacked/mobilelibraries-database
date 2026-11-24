create or replace view vw_organisations as
select
    la.id,
    c.name as country,
    la.code as service_code,
    la.code as local_authority_code,
    la.name,
    la.timetable,
    la.website,
    la.email,
    la.colour,
    la.logo,
    count(distinct m.id) as number_mobiles,
    count(distinct r.id) as number_routes,
    count(distinct s.id) as number_stops
from local_authority la
join country c on c.id = la.country_id
join mobile m on m.local_authority_id = la.id
join route r on r.mobile_id = m.id
join route_stop rs on rs.route_id = r.id
join stop s on rs.stop_id = s.id
group by la.id, c.name, la.code, la.name, la.timetable, la.website, la.email, la.colour, la.logo;
