create or replace function fn_load_stops_staging(local_authority_name character varying (200)) returns void as 
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

    -- list of new mobiles
    with new_mobiles as (
        select distinct s.mobile_name from stop_staging s
        where not exists (
            select 1 from mobile m where m.name = s.mobile_name and m.local_authority_id = var_local_authority_id
        )
        and (s.local_authority = local_authority_name or s.local_authority_code = local_authority_name)
    )
    insert into mobile (local_authority_id, name)
    select distinct var_local_authority_id, nm.mobile_name 
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
        from stop_staging s
        join mobile m on m.local_authority_id = var_local_authority_id and m.name = s.mobile_name
        where not exists (
            select 1 from route r where r.name = s.route and r.mobile_id = m.id
        )
        and (s.local_authority = local_authority_name or s.local_authority_code = local_authority_name)
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
        from stop_staging s
        join mobile m on m.name = s.mobile_name and m.local_authority_id = var_local_authority_id
        where (s.local_authority = local_authority_name or s.local_authority_code = local_authority_name)
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
        select distinct r.id as route_id, s.id as stop_id, st.day, st.arrival, st.departure, st.exceptions
        from stop_staging st
        join mobile m on m.name = st.mobile_name and m.local_authority_id = var_local_authority_id
        join route r on r.name = st.route and r.mobile_id = m.id
        join stop s on s.name = st.stop and st_setsrid(st_makepoint(st.geox, st.geoy), 4326) = s.geom
        where (st.local_authority = local_authority_name or st.local_authority_code = local_authority_name)
    )
    insert into route_stop (route_id, stop_id, day, arrival, departure, exceptions)
    select distinct rs.route_id, rs.stop_id, rs.day, rs.arrival, rs.departure, string_to_array(rs.exceptions, ',')
    from route_stops rs 
    order by rs.route_id, rs.day, rs.arrival
    on conflict (route_id, stop_id, day, arrival) do nothing;

    -- now delete the staging data for this local authority
    delete from stop_staging s where s.local_authority = local_authority_name or s.local_authority_code = local_authority_name;

end;
$$
language plpgsql;
