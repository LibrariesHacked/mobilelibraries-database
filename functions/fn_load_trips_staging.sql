create or replace function fn_load_trips_staging(organisation_name character varying (200)) returns void as 
$$
declare
    var_organisation_id integer := 0;
begin

    -- firstly, the organisation name or code must be passed in.
    if length(organisation_name) = 0 then
        raise exception 'An organisation name or code must be provided.';
    end if;

    -- find organisation by name or GSS code
    select orgs.id into var_organisation_id from (
        select id from organisation where name = organisation_name or code = organisation_name limit 1
    ) as orgs;

    if var_organisation_id = 0 OR var_organisation_id is null then
        raise exception 'Organisation not found in the database: %', organisation_name;
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
    join mobile m on m.name = s.mobile and m.organisation_id = var_organisation_id
    join stop os on os.name = s.origin_stop 
        and os.geom = st_setsrid(st_makepoint(s.origin_stop_longitude, s.origin_stop_latitude), 4326)
    join stop ds on ds.name = s.destination_stop 
        and ds.geom = st_setsrid(st_makepoint(s.destination_stop_longitude, s.destination_stop_latitude), 4326)
    on conflict (origin_stop_id, destination_stop_id) do nothing;

    delete from trip_staging;

end;
$$
language plpgsql;
