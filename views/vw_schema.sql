create view vw_schema as
select
	org.name as organisation,
	mob.name as mobile,
	rt.name as route,
	st.community as community,
	st.name as stop,
	st.address as address,
	st.postcode as postcode,
	st_x(st.geom) as geox,
	st_y(st.geom) as geoy,
	to_char(rt.start, 'day') as day,
	st.arrival as arrival,
	st.departure as departure,
	rt.frequency as frequency,
	rt.start as start,
	rt.end as end,
	case
		when st.timetable is not null then st.timetable
		when rt.timetable is not null then rt.timetable
		when mob.timetable is not null then mob.timetable
		else ''
	end as timetable
from organisation org
join mobile mob on mob.organisation_id = org.id
join route rt on rt.mobile_id = mob.id
join stop st on st.route_id = rt.id;