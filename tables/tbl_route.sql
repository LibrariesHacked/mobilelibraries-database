create table route (
	id serial,
	mobile_id integer not null,
	name character varying (200) not null,
	frequency character varying (100) not null,
	timetable character varying (200),
	"start" date not null,
	"end" date,
	constraint pk_route_id primary key (id),
	constraint fk_route_mobile_id foreign key (mobile_id) references mobile(id)
);

select addgeometrycolumn ('public', 'route', 'geom', 4326, 'MULTILINESTRING', 2);