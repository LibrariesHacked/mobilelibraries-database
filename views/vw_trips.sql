create view vw_trips as
select
    t.id as id,
    t.origin_stop_id as origin_stop_id,
    os.name as origin_stop_name,
    t.destination_stop_id as destination_stop_id,
    ds.name as destination_stop_name,
    extract(epoch from (ds.arrival - os.departure)) as scheduled_duration,
    t.distance as distance,
    t.duration as duration,
    st_asgeojson(t.geom, 5, 8)::json as route_line
from trip t
join stop os on os.id = t.origin_stop_id
join stop ds on ds.id = t.destination_stop_id;