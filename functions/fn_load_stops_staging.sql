create or replace function fn_load_stops_staging(organisation_name character varying (200)) returns void as 
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

    -- list of new mobiles
    with new_mobiles as (
        select distinct s.mobile_name from staging s
        where not exists (
            select 1 from mobile m where m.name = s.mobile_name and m.organisation_id = var_organisation_id
        )
        and (s.local_authority = organisation_name or s.local_authority_code = organisation_name)
    )
    insert into mobile (organisation_id, name)
    select distinct var_organisation_id, nm.mobile_name 
    from new_mobiles nm 
    order by nm.mobile_name;

    -- list of new routes with frequency, start, end, and timetable in a single query
    with new_routes as (
        select distinct on (m.id, s.route)
            m.id as mobile_id,
            s.route,
            s.frequency,
            s."start",
            s."end",
            s.timetable
        from staging s
        join mobile m on m.organisation_id = var_organisation_id and m.name = s.mobile_name
        where not exists (
            select 1 from route r where r.name = s.route and r.mobile_id = m.id
        )
        and (s.local_authority = organisation_name or s.local_authority_code = organisation_name)
        order by m.id, s.route, s."start"
    )
    insert into route (mobile_id, name, frequency, "start", "end", timetable)
    select nr.mobile_id, nr.route, nr.frequency, nr."start", nr."end", nr.timetable
    from new_routes nr 
    order by nr.route;

    -- list of stops (deduplicated by stop name and coordinates)
    with stops as (
        select distinct on (s.stop, s.geox, s.geoy)
            s.stop, s.community, s.address, s.postcode, s.type, s.timetable, st_setsrid(st_makepoint(s.geox, s.geoy), 4326) as geom 
        from staging s
        join mobile m on m.name = s.mobile_name and m.organisation_id = var_organisation_id
        where (s.local_authority = organisation_name or s.local_authority_code = organisation_name)
        and not exists (
            select 1 from stop existing
            where existing.name = s.stop
            and existing.geom = st_setsrid(st_makepoint(s.geox, s.geoy), 4326)
        )
        order by s.stop, s.geox, s.geoy
    )
    insert into stop (name, community, address, postcode, type, timetable, geom)
    select st.stop, st.community, st.address, st.postcode, st.type, st.timetable, st.geom 
    from stops st
    order by st.stop;

    -- route to stop mapping
    with route_stops as (
        select distinct r.id as route_id, s.id as stop_id, st.arrival, st.departure, st.exceptions
        from staging st
        join mobile m on m.name = st.mobile_name and m.organisation_id = var_organisation_id
        join route r on r.name = st.route and r.mobile_id = m.id
        join stop s on s.name = st.stop and st_setsrid(st_makepoint(st.geox, st.geoy), 4326) = s.geom
        where (st.local_authority = organisation_name or st.local_authority_code = organisation_name)
    )
    insert into route_stop (route_id, stop_id, arrival, departure, exceptions)
    select distinct rs.route_id, rs.stop_id, rs.arrival, rs.departure, string_to_array(rs.exceptions, ',')
    from route_stops rs 
    order by rs.route_id, rs.arrival
    on conflict (route_id, stop_id, arrival) do nothing;

    -- now delete the staging data for this organisation
    delete from staging s where s.local_authority = organisation_name or s.local_authority_code = organisation_name;

end;
$$
language plpgsql;
