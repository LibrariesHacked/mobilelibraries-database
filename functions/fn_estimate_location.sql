create or replace function fn_estimate_location(trip geometry, departure timestamp, arrival timestamp) returns geometry as 
$$
declare
    duration numeric := EXTRACT('epoch' FROM arrival - departure) / 60;
    elapsed numeric := EXTRACT('epoch' FROM now() - departure) / 60;
begin
    return ST_Line_Interpolate_Point(trip, (elapsed / duration));
end;
$$
language plpgsql;