create or replace function fn_stops_mvt(x integer, y integer, z integer) returns bytea as 
$$
declare 
    bbox geometry := fn_bbox(x, y, z);
begin
select ST_AsMVT(s, 'stops', 4096, 'geom')
from (
    select id, name, community, address, postcode, arrival, departure, timetable, ST_AsMvtGeom(geom, bbox, 4096, 256, true) AS geom
    from stops
    where geom && bbox
    and ST_Intersects(geom, bbox)
) as s;
end;
$$
language plpgsql;