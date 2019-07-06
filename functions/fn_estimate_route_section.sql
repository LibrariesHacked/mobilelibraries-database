create or replace function fn_estimate_route_section(trip geometry, departure timestamp, arrival timestamp, section_interval integer, smoothness numeric) returns geometry as 
$$
declare
    duration numeric := EXTRACT(EPOCH FROM (arrival - departure));
    elapsed numeric := EXTRACT(EPOCH FROM ((now() at time zone 'Europe/London') - departure));
    start_fraction numeric := (elapsed / duration);
    section_time integer := CASE WHEN (elapsed + section_interval) > duration THEN duration - elapsed ELSE section_interval END;
    end_fraction numeric := ((elapsed + section_time) / duration);
    start_point numeric := CASE WHEN start_fraction < 0 THEN 0 ELSE start_fraction END;
    end_point numeric := CASE WHEN end_fraction >= 1 THEN 1 ELSE end_fraction END;
    line_substring geometry := ST_LineSubstring(trip, start_point, end_point);
    line_length numeric := ST_Length(line_substring);
    points integer := round((section_time / smoothness));
    section_length numeric := (line_length / points);
    section geometry := ST_Segmentize(line_substring, section_length);
begin
    return section;
end;
$$
language plpgsql;