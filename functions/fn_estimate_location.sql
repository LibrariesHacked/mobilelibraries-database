create or replace function fn_estimate_location(trip geometry, departure timestamp, arrival timestamp) returns geometry as 
$$
declare
    duration numeric := EXTRACT('epoch' FROM arrival - departure);
    elapsed numeric := EXTRACT('epoch' FROM now() at time zone 'Europe/London' - departure);
    progress numeric := round((elapsed / duration), 3);
    segment_fraction numeric := CASE WHEN progress > 1 THEN 1 ELSE progress END;
begin
    return ST_LineInterpolatePoint(trip, segment_fraction);
end;
$$
language plpgsql;