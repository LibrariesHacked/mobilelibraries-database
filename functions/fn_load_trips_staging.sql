create or replace function fn_load_trips_staging(organisation_name character varying (200)) returns void as 
$$
declare
    var_organisation_id integer := 0;
begin

    -- firstly, the organisation name must be passed in.
    if length(organisation_name) = 0 then
        raise exception 'An organisation name must be provided.';
    end if;

    -- the organisation name must already be in the database
    select orgs.id into var_organisation_id from (select id from organisation where name = organisation_name) as orgs;
    if var_organisation_id = 0 OR var_organisation_id is null then
        raise exception 'Organisation not found in the database.';
    end if;

    -- list of new trips
    with trips as (
        select
            s.mobile,
            s.origin_stop,
            s.origin_stop_longitude,
            s.origin_stop_latitude,
            s.destination_stop,
            s.destination_stop_longitude,
            s.destination_stop_latitude,
            s.distance,
            s.duration,
            st_geomfromtext(s.geom, 4326) as geom
        from trip_staging s
    )
    insert into trip(origin_stop_id, destination_stop_id, distance, duration, geom)
    select
        distinct
        (select id from stop os where os.name = t.origin_stop and st_x(os.geom) = t.origin_stop_longitude and st_y(os.geom) = t.origin_stop_latitude limit 1) as origin_stop_id,
        (select id from stop ds where ds.name = t.destination_stop and st_x(ds.geom) = t.destination_stop_longitude and st_y(ds.geom) = t.destination_stop_latitude limit 1) as destination_stop_id,
        t.distance,
        t.duration,
        t.geom
    from trips t
    join mobile m on m.name = t.mobile and m.organisation_id = var_organisation_id;

    delete from trip_staging;

end;
$$
language plpgsql;