create view vw_trips as
select
    t.id as id,
    o.name as organisation_name,
    m.name as mobile_name,
    r.name as route_name,
    t.origin_stop_id as origin_stop_id,
    os.name as origin_stop_name,
    extract(epoch from (ds.arrival - os.departure)) as scheduled_duration,
    t.destination_stop_id as destination_stop_id,
    ds.name as destination_stop_name,
    t.distance as distance,
    t.duration as duration
from trip t
join stop os on os.id = t.origin_stop_id
join stop ds on ds.id = t.destination_stop_id
join route r on os.route_id = r.id
join mobile m on r.mobile_id = m.id
join organisation o on m.organisation_id = o.id;