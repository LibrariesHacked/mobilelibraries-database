create table route_stop (
	route_id integer,
	stop_id integer,
	arrival time,
	departure time,
	constraint pk_routestop_routeid_stopid_arrival primary key (route_id, stop_id, arrival),
	constraint fk_routestop_routeid foreign key (route_id) references route (id),
	constraint fk_routestop_stopid foreign key (stop_id) references stop (id)
);

create unique index idx_routestop_routeid_stopid_arrival on route_stop (route_id, stop_id, arrival);
create index idx_routestop_stopid on route_stop (stop_id);
create index idx_routestop_arrival on route_stop (arrival);
create index idx_routestop_departure on route_stop (departure);
cluster route_stop using idx_routestop_routeid_stopid_arrival;