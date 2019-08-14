create table stop (
	id serial,
	route_id integer,
	name character varying (200) not null,
	community character varying (200),
	address character varying (250),
	postcode character varying (8),
	arrival time,
	departure time,
	timetable character varying (200),
	constraint pk_stop_id primary key (id),
	constraint fk_stop_route_id foreign key (route_id) references route(id)
);

select addgeometrycolumn ('public', 'stop', 'geom', 4326, 'POINT', 2);

create unique index idx_stop_id on stop (id);
create index idx_stop_routeid on stop (route_id);
create index idx_stop_geom on stop using gist (geom);
cluster stop using idx_stop_id;