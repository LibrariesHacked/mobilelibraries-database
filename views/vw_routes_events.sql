create view vw_routes_events as
select
    r.id,
    rrule_event_instances_range(
        r.start,
        r.frequency, 
        (now() at time zone 'Europe/London')::date,
        coalesce(r.end, ((now() at time zone 'Europe/London') + interval '1 year')),
        2
    ) as date_timestamp
from route r;