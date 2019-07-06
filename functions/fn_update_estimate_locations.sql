create or replace function fn_update_estimate_locations() returns void as 
$$
declare
    last_updated timestamp := null;
    section_interval integer := 60; -- number of seconds to estimate
    smoothness numeric := 0.5; -- how often to provide a point
begin

    -- If we've estimated locations in the last 10 seconds then don't do it again - we never need to call more often
    select est.updated into last_updated from (select max(updated) as updated from location where update_type = 'Estimated') as est;
    if last_updated is not null and last_updated > (now() at time zone 'Europe/London') - interval '10 seconds' then
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
    where route_date = (now() at time zone 'Europe/London')::date
    and previous_stop_id is not null
    and next_stop_id is not null
    and route_start < (now() at time zone 'Europe/London')::time
    and route_finish > (now() at time zone 'Europe/London')::time;

    insert into location(mobile_id, section_interval, update_type, updated, geom, section)
    select
        t.mobile_id,
        section_interval,
        'Estimated',
        (now() at time zone 'Europe/London'),
        fn_estimate_location(t.geom, t.origin_departure, t.destination_arrival),
        fn_estimate_route_section(t.geom, t.origin_departure, t.destination_arrival, section_interval, smoothness)
    from mobile_trips t;

    drop table mobile_trips;
    -- Clear out old records
    delete from location
    where updated < ((now() at time zone 'Europe/London') - interval '10 seconds');

    return;

end;
$$
language plpgsql;