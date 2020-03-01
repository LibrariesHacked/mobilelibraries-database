create table route (
	id serial,
	mobile_id integer not null,
	name character varying (200) not null,
	frequency character varying (100) not null,
	timetable character varying (200),
	"start" date not null,
	"end" date,
	constraint pk_route_id primary key (id),
	constraint fk_route_mobileid foreign key (mobile_id) references mobile (id)
);

select addgeometrycolumn ('public', 'route', 'geom', 4326, 'MULTILINESTRING', 2);

create unique index idx_route_id on route (id);
create unique index idx_route_id_mobileid on route (id, mobile_id);
create index idx_route_start on route ("start");
create index idx_route_end on route ("end");
create index idx_route_frequency on route ("frequency");
create index idx_route_geom on route using gist (geom);
cluster route using idx_route_id_mobileid;