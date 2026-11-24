create or replace function fn_load_trips_staging(local_authority_name character varying (200)) returns void as 
$$
declare
    var_local_authority_id integer := 0;
begin

    -- firstly, the local authority name or code must be passed in.
    if length(local_authority_name) = 0 then
        raise exception 'A local authority name or code must be provided.';
    end if;

    -- find local authority by name or GSS code
    select auths.id into var_local_authority_id from (
        select id from local_authority where name = local_authority_name or code = local_authority_name limit 1
    ) as auths;

    if var_local_authority_id = 0 OR var_local_authority_id is null then
        raise exception 'Local authority not found in the database: %', local_authority_name;
    end if;

    -- Direct join on origin and destination stops utilizing spatial coordinates
    insert into trip (origin_stop_id, destination_stop_id, distance, duration, geom)
    select distinct
        os.id as origin_stop_id,
        ds.id as destination_stop_id,
        s.distance,
        s.duration,
        st_geomfromtext(s.geom, 4326) as geom
    from trip_staging s
    join mobile m on m.name = s.mobile and m.local_authority_id = var_local_authority_id
    join stop os on os.name = s.origin_stop 
        and os.geom = st_setsrid(st_makepoint(s.origin_stop_longitude, s.origin_stop_latitude), 4326)
    join stop ds on ds.name = s.destination_stop 
        and ds.geom = st_setsrid(st_makepoint(s.destination_stop_longitude, s.destination_stop_latitude), 4326)
    on conflict (origin_stop_id, destination_stop_id) do nothing;

    delete from trip_staging;

end;
$$
language plpgsql;
