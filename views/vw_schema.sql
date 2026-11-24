create or replace view vw_schema as
select
	-- Official v2.0.0 schema fields conforming to schema.librarydata.uk/mobile-library-stops.json
	la.name as local_authority,
	la.code as local_authority_code,
	mob.name as mobile_name,
	rt.name as route,
	st.community as community,
	st.name as stop,
	st.address as address,
	st.postcode as postcode,
	st_x(st.geom) as geox,
	st_y(st.geom) as geoy,
	rs.day as day,
	coalesce(st.type, 'Public') as type,
	rs.arrival as arrival,
	rs.departure as departure,
	rt.frequency as frequency,
	rt.start as start,
	rt.end as end,
	coalesce(array_to_string(rs.exceptions, ','), '') as exceptions,
	coalesce(nullif(st.timetable, ''), nullif(rt.timetable, ''), nullif(mob.timetable, ''), '') as timetable,

	-- Backwards compatibility aliases for API and older consumers
	la.name as organisation,
	mob.name as mobile,
	la.name as "Local authority",
	la.code as "Local authority code",
	mob.name as "Mobile name",
	rt.name as "Route",
	st.community as "Community",
	st.name as "Stop",
	st.address as "Address",
	st.postcode as "Postcode",
	st_x(st.geom) as "GeoX",
	st_y(st.geom) as "GeoY",
	rs.day as "Day",
	coalesce(st.type, 'Public') as "Type",
	rs.arrival as "Arrival",
	rs.departure as "Departure",
	rt.frequency as "Frequency",
	rt.start as "Start",
	rt.end as "End",
	coalesce(array_to_string(rs.exceptions, ','), '') as "Exceptions",
	coalesce(nullif(st.timetable, ''), nullif(rt.timetable, ''), nullif(mob.timetable, ''), '') as "Timetable"
from local_authority la
join mobile mob on mob.local_authority_id = la.id
join route rt on rt.mobile_id = mob.id
join route_stop rs on rs.route_id = rt.id
join stop st on st.id = rs.stop_id;
