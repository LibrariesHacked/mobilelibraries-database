create or replace function fn_update_route_dates() returns void as 
$$
declare
    last_updated date := null;
begin

    -- If we've estimated locations in the last day then don't do it again
    select updated::date into last_updated from updates where type = 'route_dates';
    if last_updated is not null and last_updated > (now() at time zone 'Europe/London')::date then
        return;
    end if;

    create temp table temp_route_dates (
        route_id int,
        route_date date
    );

    -- get the route dates
    insert into temp_route_dates(route_id, route_date)
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

    truncate route_dates;
    insert into route_dates(route_id, route_date)
    select route_id, route_date from temp_route_dates;

    drop table temp_route_dates; 

    -- now update the updates table
    if last_updated is not null then
        update updates set updated = (now() at time zone 'Europe/London') where type = 'route_dates';
    else
        insert into updates (type, updated) values ('routes_dates', (now() at time zone 'Europe/London'));
    end if;

    return;

end;
$$
language plpgsql;