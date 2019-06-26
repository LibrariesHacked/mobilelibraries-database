create or replace function fn_update_estimate_locations() returns void as 
$$
declare
    last_updated timestamp := null;
begin

    -- If we've estimated locations in the last minute then don't do it again
    select est.updated into last_updated from (select max(updated) as updated from location where update_type = 'Estimated') as est;
    if last_updated is not null and last_updated > now() - interval '1 minute' then
        return;
    end if;

    -- Find all the currently active mobiles
    create temp table mobile_trips (
        mobile_id int,
        origin_stop_id int,
        origin_departure timestamp,
        destination_stop_id int,
        destination_arrival timestamp,
        geom geometry
    );

    -- the only ones we're interested in are those 'on the road'
    -- that is active today, not at a stop, and within their route start and finish
    insert into mobile_trips(mobile_id, origin_stop_id, origin_departure, destination_stop_id, destination_arrival, geom)
    select 
        s.mobile_id,
        s.previous_stop_id,
        s.previous_stop_departure,
        s.next_stop_id,
        s.next_stop_arrival, 
        t.geom
    from vw_mobiles_status s
    join trip t on t.origin_stop_id = s.previous_stop_id and t.destination_stop_id = s.next_stop_id
    where route_date = now()::date
    and previous_stop_id is not null
    and next_stop_id is not null
    and route_start < now()::time
    and route_finish > now()::time;

    insert into location(mobile_id, update_type, updated, geom)
    select
        t.mobile_id,
        'Estimated',
        now(),
        fn_estimate_location(t.geom, t.origin_departure, t.destination_arrival)
    from mobile_trips t;

    drop table mobile_trips;
    -- Clear out old records
    delete from location
    where updated < (now() - interval '1 minute');

    return;

end;
$$
language plpgsql;