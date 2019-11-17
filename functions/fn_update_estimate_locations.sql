create or replace function fn_update_estimate_locations() returns void as 
$$
declare
    last_updated timestamp := null;
    section_interval integer := 60; -- number of seconds to estimate
    smoothness numeric := 0.5; -- how often to provide a point
begin

    -- If we've estimated locations in the last 15 seconds then don't do it again
    select updated into last_updated from updates where type = 'estimated_location';
    if last_updated is not null and last_updated > (now() at time zone 'Europe/London') - interval '15 seconds' then
        return;
    end if;

    -- Find all the currently active mobiles
    create temp table temp_mobile_trips (
        mobile_id int,
        origin_stop_id int,
        origin_departure timestamp,
        destination_stop_id int,
        destination_arrival timestamp,
        geom geometry
    );

    -- the only ones we're interested in are those 'on the road'
    -- active today, not at a stop, and within their route start and finish
    insert into temp_mobile_trips(mobile_id, origin_stop_id, origin_departure, destination_stop_id, destination_arrival, geom)
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

    truncate location;
    insert into location(mobile_id, section_interval, update_type, updated, geom, section)
    select
        t.mobile_id,
        section_interval,
        'Estimated',
        (now() at time zone 'Europe/London'),
        fn_estimate_location(t.geom, t.origin_departure, t.destination_arrival),
        fn_estimate_route_section(t.geom, t.origin_departure, t.destination_arrival, section_interval, smoothness)
    from temp_mobile_trips t;

    drop table temp_mobile_trips;

    -- now update the updates table
    if last_updated is not null then
        update updates set updated = (now() at time zone 'Europe/London') where type = 'estimated_location';
    else
        insert into updates (type, updated) values ('estimated_location', (now() at time zone 'Europe/London'));
    end if;

    return;

end;
$$
language plpgsql;