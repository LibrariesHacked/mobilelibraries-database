create or replace function fn_estimate_location(trip geometry, departure timestamp, arrival timestamp) returns geometry as 
$$
declare
    duration integer := datediff(dd, departure, arrival);
    elapsed integer := datediff(dd, departure, now());
begin

    return ST_Line_Interpolate_Point(trip, (elapsed/duration));
end;
$$
language plpgsql;