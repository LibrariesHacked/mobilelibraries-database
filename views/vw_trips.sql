create view vw_trips as
select
    t.id as id,
    t.origin_stop_id as origin_stop_id,
    t.destination_stop_id as destination_stop_id,
    t.distance as distance,
    t.duration as duration
from trip t;