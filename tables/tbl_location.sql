create table location (
	id serial,
	mobile_id integer,
	section_interval integer,
	update_type character varying (10),
	updated timestamp with time zone,
	constraint pk_location_id primary key (id),
	constraint fk_location_mobile_id foreign key (mobile_id) references mobile (id)
);

select addgeometrycolumn ('public', 'location', 'geom', 4326, 'POINT', 2);
select addgeometrycolumn ('public', 'location', 'section', 4326, 'LINESTRING', 2);

create unique index idx_location_id on location (id);
create index idx_location_mobileid on location (mobile_id);
create index idx_location_geom on location using gist (geom);
create index idx_location_section on location using gist (section);
cluster location using idx_location_id;