create or replace view vw_schema as
select
	-- Schema conforming to LibrariesHacked schema-librarydata/mobile-library-stops.json
	org.name as "Local authority",
	org.code as "Local authority code",
	mob.name as "Mobile name",
	rt.name as "Route",
	st.community as "Community",
	st.name as "Stop",
	st.address as "Address",
	st.postcode as "Postcode",
	st_x(st.geom) as "GeoX",
	st_y(st.geom) as "GeoY",
	trim(to_char(rt.start, 'Day')) as "Day",
	coalesce(st.type, 'Public') as "Type",
	rs.arrival as "Arrival",
	rs.departure as "Departure",
	rt.frequency as "Frequency",
	rt.start as "Start",
	rt.end as "End",
	array_to_string(rs.exceptions, ',') as "Exceptions",
	case
		when st.timetable is not null and st.timetable <> '' then st.timetable
		when rt.timetable is not null and rt.timetable <> '' then rt.timetable
		when mob.timetable is not null and mob.timetable <> '' then mob.timetable
		else ''
	end as "Timetable",

	-- Lowercase aliases for API and internal backwards compatibility
	org.name as organisation,
	org.code as local_authority_code,
	mob.name as mobile,
	rt.name as route,
	st.community as community,
	st.name as stop,
	st.address as address,
	st.postcode as postcode,
	st_x(st.geom) as geox,
	st_y(st.geom) as geoy,
	trim(to_char(rt.start, 'Day')) as day,
	coalesce(st.type, 'Public') as type,
	rs.arrival as arrival,
	rs.departure as departure,
	rt.frequency as frequency,
	rt.start as start,
	rt.end as end,
	array_to_string(rs.exceptions, ',') as exceptions,
	case
		when st.timetable is not null and st.timetable <> '' then st.timetable
		when rt.timetable is not null and rt.timetable <> '' then rt.timetable
		when mob.timetable is not null and mob.timetable <> '' then mob.timetable
		else ''
	end as timetable
from organisation org
join mobile mob on mob.organisation_id = org.id
join route rt on rt.mobile_id = mob.id
join route_stop rs on rs.route_id = rt.id
join stop st on st.id = rs.stop_id;
