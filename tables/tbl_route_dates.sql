create table route_dates (
	id serial,
	route_id integer not null,
	route_date date,
	constraint pk_routedates_id primary key (id),
	constraint fk_routedates_route_id foreign key (route_id) references route(id)
);

create unique index idx_routedates_id on route_dates (id);
create index idx_routedates_routedate on route_dates (route_date);
create unique index idx_routedates_routeid_routedate on route_dates (route_id, route_date);
cluster route_dates using idx_routedates_id;