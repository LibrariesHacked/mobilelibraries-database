create or replace function fn_update_route_schedule() returns void as 
$$
declare
    last_updated date := null;
begin

    -- If we've updated route dates in the last day then don't do it again
    select updated::date into last_updated from updates where type = 'route_schedule';
    if last_updated is not null and last_updated >= (now() at time zone 'Europe/London')::date then
        return;
    end if;

    create temp table temp_route_schedule (
        route_id int,
        visit date
    );

    -- get the route dates
    insert into temp_route_schedule(route_id, visit)
    select
        r.id,
        rrule_event_instances_range(
            r.start,
            r.frequency, 
            (now() at time zone 'Europe/London')::date,
            coalesce(r.end, ((now() at time zone 'Europe/London') + interval '1 year')),
            30
        )
    from route r;

    delete from route_schedule;

    insert into route_schedule(route_id, visit)
    select route_id, visit from temp_route_schedule;

    drop table temp_route_schedule; 

    -- now update the updates table
    if last_updated is not null then
        update updates set updated = (now() at time zone 'Europe/London') where type = 'route_schedule';
    else
        insert into updates (type, updated) values ('route_schedule', (now() at time zone 'Europe/London'));
    end if;

    return;

end;
$$
language plpgsql;