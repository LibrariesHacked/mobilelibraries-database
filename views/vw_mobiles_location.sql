create view vw_mobiles_location as
select
    ms.mobile_id as mobile_id,
    case
        when l.geom is not null then l.geom
        when l.geom is null and current_stop_id is not null then
            (select geom from stop where id = current_stop_id)
        else null
    end as location_geom,
    ms.current_stop_id,
    ms.current_stop_departure,
    ms.current_stop_name,
    ms.previous_stop_id,
    ms.previous_stop_departure,
    ms.previous_stop_name,
    ms.next_stop_id,
    ms.next_stop_arrival,
    ms.next_stop_name,
    l.updated as location_updated,
    l.update_type as update_type
from vw_mobiles_status ms
left join location l on l.mobile_id = ms.mobile_id;