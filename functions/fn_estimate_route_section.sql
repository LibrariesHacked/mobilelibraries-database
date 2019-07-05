create or replace function fn_estimate_route_section(trip geometry, departure timestamp, arrival timestamp, section_interval integer, smoothness integer) returns geometry as 
$$
declare
    duration numeric := EXTRACT('epoch' FROM arrival - departure) / 60;
    elapsed numeric := EXTRACT('epoch' FROM now() at time zone 'Europe/London' - departure) / 60;
    start_fraction numeric := (elapsed / duration);
    end_fraction numeric := ((elapsed + section_interval) / duration);
    start_point numeric := CASE WHEN start_fraction < 0 THEN 0 ELSE start_fraction END;
    end_point numeric := CASE WHEN end_fraction > 1 THEN 1 ELSE end_fraction END;
    line_substring geometry := ST_LineSubstring(trip, start_point, end_point);
    line_length numeric := ST_Length(line_substring);
    points integer := round((section_interval / smoothness));
    section_length numeric := (line_length / points);
    section geometry := ST_Segmentize(line_substring, section_length);
begin
    return section;
end;
$$
language plpgsql;