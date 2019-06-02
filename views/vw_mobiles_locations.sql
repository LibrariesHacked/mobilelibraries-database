create view vw_mobiles_locations as
select
    l.id as id,
    l.mobile_id as mobile_id,
    st_x(l.geom) as longitude,
    st_y(l.geom) as latitude,
    l.updated as updated,
    l.update_type as update_type
from vw_mobiles_status ms
left join location l on l.mobile_id = ms.mobile_id;