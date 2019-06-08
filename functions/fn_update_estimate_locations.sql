create or replace function fn_update_estimate_locations() returns void as 
$$
begin

    -- Find all the currently active mobiles
    create temp table mobile_trips (
        mobile_id int,
        origin_stop_id int,
        origin_departure timestamp with time zone,
        destination_stop_id int,
        destination_arrival timestamp with time zone,
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
        fn_estimate_location(t.geom, t.previous_stop_departure, t.next_stop_arrival)
    from mobile_trips t;

    drop table mobile_trips;
    -- Clear out old records
    delete from location
    where updated < (now() - interval '1 minute');

end;
$$
language plpgsql;