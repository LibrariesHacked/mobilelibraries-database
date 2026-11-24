create table stop (
	id serial,
	name character varying (200) not null,
	community character varying (200),
	address character varying (250),
	postcode character varying (8),
	type character varying (200) not null default 'Public',
	timetable character varying (200),
	constraint pk_stop_id primary key (id),
	constraint ck_stop_type check (type in ('Public', 'Private', 'Dynamic', 'Other'))
);

select addgeometrycolumn ('public', 'stop', 'geom', 4326, 'POINT', 2);

create unique index idx_stop_id on stop (id);
create unique index idx_stop_id_name on stop (id, name);
create index idx_stop_geom on stop using gist (geom);
create index idx_stop_type on stop (type);
cluster stop using idx_stop_id;
