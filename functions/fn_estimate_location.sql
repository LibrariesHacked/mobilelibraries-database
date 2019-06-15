create or replace function fn_estimate_location(trip geometry, departure timestamp with time zone, arrival timestamp with time zone) returns geometry as 
$$
declare
    duration integer := EXTRACT('epoch' FROM arrival - departure) / 60;
    elapsed integer := EXTRACT('epoch' FROM now() - departure) / 60;
begin
    return ST_Line_Interpolate_Point(trip, (elapsed/duration));
end;
$$
language plpgsql;