create or replace function fn_load_stops_staging(organisation_name character varying (200)) returns void as 
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

    -- list of new mobiles
    with new_mobiles as (
        select distinct mobile from staging s
        where not exists(select 1 from mobile m where m.name = s.mobile and m.organisation_id = var_organisation_id)
        and s.organisation = organisation_name
    )
    -- insert new mobiles
    insert into mobile (organisation_id, name)
    select distinct var_organisation_id, nm.mobile 
    from new_mobiles nm 
    order by nm.mobile;

    -- list of new routes
    with new_routes as (
        select distinct m.id as mobile_id, s.route from staging s
        join mobile m on m.organisation_id = var_organisation_id and m.name = s.mobile
        where not exists(select 1 from route r where r.name = s.route and r.mobile_id = m.id)
    )
    -- insert new routes
    insert into route (mobile_id, name, frequency, "start", "end")
    select 
        nr.mobile_id, 
        nr.route, 
        (select frequency from staging s where s.organisation = organisation_name and s.route = nr.route limit 1),
        (select "start" from staging s where s.organisation = organisation_name and s.route = nr.route limit 1),
        (select "end" from staging s where s.organisation = organisation_name and s.route = nr.route limit 1)
    from new_routes nr 
    order by nr.route;

    --list of stops
    with stops as (
        select distinct s.stop, s.community, s.address, s.postcode, s.timetable, st_setsrid(st_makepoint(s.geox, s.geoy), 4326) as geom 
        from staging s
        join mobile m on m.name = s.mobile and m.organisation_id = var_organisation_id
        join organisation o on o.id = var_organisation_id and m.organisation_id = o.id
    )
    insert into stop (name, community, address, postcode, timetable, geom)
    select st.stop, st.community, st.address, st.postcode, st.timetable, st.geom 
    from stops st
    order by st.stop;

    -- route to stop mapping
    with route_stops as (
        select distinct r.id as route_id, s.id as stop_id, st.arrival, st.departure
        from staging st
        join mobile m on m.name = st.mobile and m.organisation_id = var_organisation_id
        join organisation o on o.id = var_organisation_id and m.organisation_id = o.id
        join route r on r.name = st.route and r.mobile_id = m.id
        join stop s on s.name = st.stop and st_setsrid(st_makepoint(st.geox, st.geoy), 4326) = s.geom
    )
    insert into route_stop (route_id, stop_id, arrival, departure)
    select distinct rs.route_id, rs.stop_id, rs.arrival, rs.departure 
    from route_stops rs 
    order by rs.route_id, rs.arrival;

    -- now delete the staging data
    delete from staging s where s.organisation = organisation_name;

end;
$$
language plpgsql;