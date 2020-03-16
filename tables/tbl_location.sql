create table location (
	mobile_id integer,
	section_interval integer,
	update_type character varying (10),
	updated timestamp with time zone,
	constraint pk_location_mobileid_updatetype primary key (mobile_id, update_type),
	constraint fk_location_mobileid foreign key (mobile_id) references mobile (id)
);

select addgeometrycolumn ('public', 'location', 'geom', 4326, 'POINT', 2);
select addgeometrycolumn ('public', 'location', 'section', 4326, 'LINESTRING', 2);

create unique index idx_location_mobileid_updatetype on location (mobile_id, update_type);
create index idx_location_geom on location using gist (geom);
create index idx_location_section on location using gist (section);
cluster location using idx_location_mobileid_updatetype;