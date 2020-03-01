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
return query (
    with stops as (
        select
            distinct
            r.mobile_id as mobile_id,
            s.id as stop_id,
            s.name as stop_name,
            s.geom as stop_geom,
            round(st_distance(st_transform(s.geom, 27700), search_point))::integer as stop_distance
        from stop s
        join route_stop rs on rs.stop_id = s.id
        join route r on r.id = rs.route_id
        where st_dwithin(st_transform(s.geom, 27700), search_point, distance)
    )
    select
        st.mobile_id as mobile_id,
        st.stop_id as stop_id,
        st.stop_name as stop_name,
        st.stop_distance as stop_distance
    from stops st
    join (
        select stops.mobile_id as mobile_id, min(stops.stop_distance) as stop_distance
        from stops
        group by stops.mobile_id
    ) as st2 on st2.stop_distance = st.stop_distance and st.mobile_id = st2.mobile_id
    order by mobile_id
);
end;
$$
language plpgsql;