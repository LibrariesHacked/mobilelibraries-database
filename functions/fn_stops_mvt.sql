create or replace function fn_stops_mvt(x integer, y integer, z integer) returns bytea as 
$$
declare 
    bbox geometry := fn_bbox(x, y, z);
	tile bytea;
begin
select st_asmvt(s, 'stop', 4096, 'mvt_geom') into tile
from (
    select
        id,
        name,
        organisation_colour,
        to_char(((concat(route_schedule->>0, ' ', arrival)::timestamp)), 'FMHH:MIpm on DDth Month') as next_visiting,
        st_asmvtgeom(st_transform(geom, 3857), bbox, 4096, 256, true) as mvt_geom
    from vw_stops
    where route_schedule->>0 is not null
    and st_intersects(st_transform(geom, 3857), bbox)
) as s;
return tile;
end;
$$
language plpgsql;