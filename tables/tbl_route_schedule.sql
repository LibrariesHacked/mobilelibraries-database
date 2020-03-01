create table route_schedule (
	id serial,
	route_id integer not null,
	visit date,
	constraint pk_routeschedule_id primary key (id),
	constraint fk_routeschedule_routeid foreign key (route_id) references route(id)
);

create unique index idx_routeschedule_id on route_schedule (id);
create unique index idx_routeschedule_routeid_visit on route_schedule (route_id, visit);
cluster route_schedule using idx_routeschedule_routeid_visit;