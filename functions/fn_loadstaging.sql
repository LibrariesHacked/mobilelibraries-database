create or replace function fn_loadstaging(organisation_name character varying (200)) returns void as 
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
        where not exists(select 1 from mobile m where m.name = s.mobile)
        and s.organisation = organisation_name
    )
    -- insert new mobiles
    insert into mobile (organisation_id, name)
    select var_organisation_id, nm.mobile from new_mobiles nm;

    -- list of new routes
    with new_routes as (
        select distinct m.id as mobile_id, s.route, s.frequency, s.start, s.end from staging s
        join mobile m on m.organisation_id = var_organisation_id and m.name = s.mobile
        where not exists(select 1 from route r where r.name = s.route and r.mobile_id = m.id)
    )
    -- insert new routes
    insert into route (mobile_id, name, frequency, "start", "end")
    select nr.mobile_id, nr.route, nr.frequency, nr.start, nr.end from new_routes nr;

    --list of stops
    with stops as (
        select distinct r.id as route_id, s.stop, s.community, s.address, s.postcode, s.arrival, s.departure, s.timetable, st_setsrid(st_makepoint(s.geox, s.geoy), 4326) as geom from staging s
        join route r on r.name = s.route
        join mobile m on m.name = s.mobile and m.organisation_id = var_organisation_id
        join organisation o on o.id = var_organisation_id and m.organisation_id = o.id
    )
    insert into stop (route_id, name, community, address, postcode, arrival, departure, timetable, geom)
    select st.route_id, st.stop, st.community, st.address, st.postcode, st.arrival, st.departure, st.timetable, st.geom from stops st;

    -- now delete the staging data
    delete from staging s where s.organisation = organisation_name;

end;
$$
language plpgsql;