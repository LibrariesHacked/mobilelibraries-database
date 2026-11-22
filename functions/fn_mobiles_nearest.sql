create or replace function fn_mobiles_nearest(longitude numeric, latitude numeric, distance integer) returns 
    table (
        mobile_id integer,
        stop_id integer,
        stop_name character varying (200),
        stop_distance integer
    ) as
$$
declare
    search_point geometry := st_transform(st_setsrid(st_makepoint(longitude, latitude), 4326), 27700);
begin
return query
    select distinct on (r.mobile_id)
        r.mobile_id,
        s.id as stop_id,
        s.name as stop_name,
        round(st_distance(st_transform(s.geom, 27700), search_point))::integer as stop_distance
    from stop s
    join route_stop rs on rs.stop_id = s.id
    join route r on r.id = rs.route_id
    where st_dwithin(st_transform(s.geom, 27700), search_point, distance)
    order by r.mobile_id, st_distance(st_transform(s.geom, 27700), search_point) asc;
end;
$$
language plpgsql;
