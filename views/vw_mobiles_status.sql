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
	st.current_stop_id,
	st.current_stop_departure,
	cs.name as current_stop_name,
	st.previous_stop_id,
	st.previous_stop_departure,
	ps.name as previous_stop_name,
	st.next_stop_id,
	st.next_stop_arrival,
	ns.name as next_stop_name
from 
	( select
		t.mobile_id,
		min(t.arrival::date) as route_date,
		min(t.arrival::time) as route_start,
		max(t.departure::time) as route_finish,
		( select id
			from stops ct
			where ct.mobile_id = t.mobile_id
			and ct.departure <= now()
			and ct.arrival >= now() limit 1 ) as current_stop_id,
		( select departure
			from stops ct
			where ct.mobile_id = t.mobile_id
			and ct.departure <= now()
			and ct.arrival >= now() limit 1 ) as current_stop_departure,
		( select id
			from stops pt
			where pt.mobile_id = t.mobile_id
			and pt.departure < now()
			order by pt.departure desc limit 1 ) as previous_stop_id,
		( select departure
			from stops pt
			where pt.mobile_id = t.mobile_id
			and pt.departure < now()
			order by pt.departure desc limit 1 ) as previous_stop_departure,
		( select id
			from stops nt
			where nt.mobile_id = t.mobile_id
			and nt.arrival > now()
			order by nt.arrival asc limit 1 ) as next_stop_id,
		( select arrival
			from stops nt
			where nt.mobile_id = t.mobile_id
			and nt.arrival > now()
			order by nt.arrival asc limit 1 ) as next_stop_arrival
	from vw_stops_timetable t
	group by t.mobile_id ) st
left join stop cs on cs.id = current_stop_id
left join stop ps on ps.id = previous_stop_id
left join stop ns on ns.id = next_stop_id;