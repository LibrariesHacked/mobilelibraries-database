create or replace function fn_load_trips_staging() returns void as 
$$
begin

    with trips as (
        select
            s.mobile,
            s.route,
            s.origin_stop,
            s.origin_stop_longitude,
            s.origin_stop_latitude,
            s.destination_stop,
            s.destination_stop_longitude,
            s.destination_stop_latitude,
            s.distance,
            s.duration,
            st_geomfromtext(s.geom, 4326) as geom
        from trip_staging s)
    insert into trip(route_id, origin_stop_id, destination_stop_id, distance, duration, geom)
    select
        distinct
		r.id,
        (select id from stop os where os.route_id = r.id and os.name = t.origin_stop and st_x(os.geom) = t.origin_stop_longitude and st_y(os.geom) = t.origin_stop_latitude limit 1) as origin_stop_id,
        (select id from stop ds where ds.route_id = r.id and ds.name = t.destination_stop and st_x(ds.geom) = t.destination_stop_longitude and st_y(ds.geom) = t.destination_stop_latitude limit 1) as destination_stop_id,
        t.distance,
        t.duration,
        t.geom
    from trips t
    join mobile m on m.name = t.mobile
    join route r on r.name = t.route;

    delete from trip_staging;

end;
$$
language plpgsql;