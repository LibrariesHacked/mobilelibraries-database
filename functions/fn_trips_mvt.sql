create or replace function fn_trips_mvt(x integer, y integer, z integer) returns bytea as 
$$
declare 
    bbox geometry := fn_bbox(x, y, z);
    bbox_4326 geometry := st_transform(bbox, 4326);
	tile bytea;
begin
select st_asmvt(s, 'trip', 4096, 'mvt_geom') into tile
from (
    select id, origin_stop_id, destination_stop_id, distance, duration, st_asmvtgeom(st_transform(geom, 3857), bbox, 4096, 256, true) as mvt_geom
    from trip
    where st_intersects(geom, bbox_4326)
) as s;
return tile;
end;
$$
language plpgsql;
