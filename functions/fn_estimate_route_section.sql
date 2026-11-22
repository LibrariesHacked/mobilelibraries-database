create or replace function fn_estimate_route_section(trip geometry, departure timestamp, arrival timestamp, section_interval integer, smoothness numeric) returns geometry as 
$$
declare
    duration numeric;
    elapsed numeric;
    start_fraction numeric;
    section_time numeric;
    end_fraction numeric;
    start_point numeric;
    end_point numeric;
    line_substring geometry;
    line_length numeric;
    points integer;
    section_length numeric;
begin
    if trip is null then
        return null;
    end if;

    duration := EXTRACT(EPOCH FROM (arrival - departure));
    if duration is null or duration <= 0 then
        return ST_StartPoint(trip);
    end if;

    elapsed := EXTRACT(EPOCH FROM ((now() at time zone 'Europe/London') - departure));
    start_fraction := greatest(0.0, least(1.0, elapsed / duration));
    section_time := greatest(1.0, least(section_interval::numeric, duration - elapsed));
    end_fraction := greatest(start_fraction, least(1.0, (elapsed + section_time) / duration));

    start_point := round(start_fraction, 3);
    end_point := round(end_fraction, 3);

    if start_point >= end_point then
        return ST_LineInterpolatePoint(trip, start_point);
    end if;

    line_substring := ST_LineSubstring(trip, start_point, end_point);
    line_length := ST_Length(line_substring);

    if smoothness is null or smoothness <= 0 then
        smoothness := 0.5;
    end if;

    points := greatest(1, round(section_time / smoothness)::integer);
    section_length := line_length / points;

    if section_length <= 0 then
        return line_substring;
    end if;

    return ST_Segmentize(line_substring, section_length);
end;
$$
language plpgsql;
