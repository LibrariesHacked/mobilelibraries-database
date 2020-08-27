create view vw_mobiles_location as
select 
    ms.mobile_id,
    ms.current_stop_id,
    ms.current_stop_departure,
    ms.current_stop_name,
    ms.previous_stop_id,
    ms.previous_stop_departure,
    ms.previous_stop_name,
    ms.next_stop_id,
    ms.next_stop_arrival,
    ms.next_stop_name,
    coalesce(st_x(coalesce(l.geom, cs.geom)), null) as geox,
    coalesce(st_y(coalesce(l.geom, cs.geom)), null) as geoy,
    st_asgeojson(l.section)::json as route_section,
    l.update_type,
    l.updated
from vw_mobiles_status ms
left join stop cs on cs.id = ms.current_stop_id
left join location l on l.mobile_id = ms.mobile_id;