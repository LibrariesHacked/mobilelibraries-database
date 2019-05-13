create or replace function fn_stops_mvt(x integer, y integer, z integer) returns bytea as 
$$
declare 
    bbox geometry := fn_bbox(x, y, z);
	tile bytea;
begin
select st_asmvt(s, 'stop', 4096, 'mvt_geom') into tile
from (
    select id, name, community, address, postcode, arrival, departure, timetable, st_asmvtgeom(st_transform(geom, 3857), bbox, 4096, 256, true) as mvt_geom
    from stop
    where st_intersects(st_transform(geom, 3857), bbox)
) as s;
return tile;
end;
$$
language plpgsql;