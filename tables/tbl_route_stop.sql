create table route_stop (
	route_id integer,
	stop_id integer,
	day character varying (9) not null,
	arrival time,
	departure time,
	exceptions text[],
	constraint pk_routestop_routeid_stopid_day_arrival primary key (route_id, stop_id, day, arrival),
	constraint fk_routestop_routeid foreign key (route_id) references route (id),
	constraint fk_routestop_stopid foreign key (stop_id) references stop (id),
	constraint ck_routestop_day check (day in ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'))
);

create unique index idx_routestop_routeid_stopid_day_arrival on route_stop (route_id, stop_id, day, arrival);
create index idx_routestop_routeid_stopid on route_stop (route_id, stop_id);
create index idx_routestop_stopid on route_stop (stop_id);
create index idx_routestop_day on route_stop (day);
create index idx_routestop_arrival on route_stop (arrival);
create index idx_routestop_departure on route_stop (departure);
cluster route_stop using idx_routestop_routeid_stopid_day_arrival;
