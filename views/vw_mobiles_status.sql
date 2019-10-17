create view vw_mobiles_status as
with stops as (
	select id, arrival, departure, mobile_id
	from vw_stops_timetable
)
select 
	st.mobile_id,
	st.route_date,
	st.route_start,
	st.route_finish,
	st.current_stop -> 'id' as current_stop_id,
	st.current_stop -> 'departure' as current_stop_departure,
	st.current_stop -> 'name' as current_stop_name,
	st.previous_stop -> 'id' as previous_stop_id,
	st.previous_stop -> 'departure' as previous_stop_departure,
	st.previous_stop -> 'name' as previous_stop_name,
	st.next_stop -> 'id' as next_stop_id,
	st.next_stop -> 'arrival' as next_stop_arrival,
	st.next_stop -> 'name' as next_stop_name
from 
	( select
		t.mobile_id,
		min(t.arrival::date) as route_date,
		min(t.arrival::time) as route_start,
		max(t.departure::time) as route_finish,
		( select row_to_json(ct.*)
			from stops ct
			where ct.mobile_id = t.mobile_id
			and ct.departure > now() at time zone 'Europe/London'
			and ct.arrival <= now() at time zone 'Europe/London' limit 1 ) as current_stop,
		( select row_to_json(pt.*)
			from stops pt
			where pt.mobile_id = t.mobile_id
			and pt.departure < now() at time zone 'Europe/London'
			order by pt.departure desc limit 1 ) as previous_stop,
		( select row_to_json(nt.*)
			from stops nt
			where nt.mobile_id = t.mobile_id
			and nt.arrival > now() at time zone 'Europe/London'
			order by nt.arrival asc limit 1 ) as next_stop
	from stops t
	group by t.mobile_id ) st;