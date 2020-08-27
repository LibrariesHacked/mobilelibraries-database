create table stop (
	id serial,
	name character varying (200) not null,
	community character varying (200),
	address character varying (250),
	postcode character varying (8),
	type character varying (200),
	timetable character varying (200),
	constraint pk_stop_id primary key (id)
);

select addgeometrycolumn ('public', 'stop', 'geom', 4326, 'POINT', 2);

create unique index idx_stop_id on stop (id);
create unique index idx_stop_id_name on stop (id, name);
create index idx_stop_geom on stop using gist (geom);
cluster stop using idx_stop_id;