create or replace function fn_stops_mvt(x integer, y integer, z integer) returns bytea as 
$$
declare 
    bbox geometry := fn_bbox(x, y, z);
    bbox_4326 geometry := st_transform(bbox, 4326);
	tile bytea;
begin
select st_asmvt(s, 'stop', 4096, 'mvt_geom') into tile
from (
    select
        id,
        name,
        organisation_colour,
        to_char(route_schedule[1], 'DDth FMMonth FMHH:MIpm') as next_visiting,
        st_asmvtgeom(st_transform(geom, 3857), bbox, 4096, 256, true) as mvt_geom
    from vw_stops
    where route_schedule[1] is not null
    and st_intersects(geom, bbox_4326)
) as s;
return tile;
end;
$$
language plpgsql;
