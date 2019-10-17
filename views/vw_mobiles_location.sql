create view vw_mobiles_location as
with locations as
    (select 
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
        case
            when l.geom is not null then l.geom
            when l.geom is null and current_stop_id is not null then
                (select geom from stop where id = current_stop_id)
            else null
        end as location_geom,
        l.section as route_section,
        l.update_type,
        l.updated
    from vw_mobiles_status ms
    left join location l on l.mobile_id = ms.mobile_id)
select 
    mobile_id,
    current_stop_id,
    current_stop_departure,
    current_stop_name,
    previous_stop_id,
    previous_stop_departure,
    previous_stop_name,
    next_stop_id,
    next_stop_arrival,
    next_stop_name,
    coalesce(st_x(location_geom), null) as geox,
    coalesce(st_y(location_geom), null) as geoy,
    st_asgeojson(route_section)::json as route_section,
    update_type,
    updated
from locations;