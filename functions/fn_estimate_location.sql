create or replace function fn_estimate_location(trip geometry, departure timestamp, arrival timestamp) returns geometry as 
$$
declare
    duration numeric := EXTRACT('epoch' FROM (arrival - departure));
    elapsed numeric := EXTRACT('epoch' FROM ((now() at time zone 'Europe/London') - departure));
    progress numeric;
    segment_fraction numeric;
begin
    if trip is null then
        return null;
    end if;

    if duration is null or duration <= 0 then
        return ST_StartPoint(trip);
    end if;

    progress := elapsed / duration;
    segment_fraction := greatest(0.0, least(1.0, round(progress, 3)));

    return ST_LineInterpolatePoint(trip, segment_fraction);
end;
$$
language plpgsql;
