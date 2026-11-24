create table mobile_location (
	mobile_id integer,
	section_interval integer,
	update_type character varying (10),
	updated timestamp with time zone,
	constraint pk_mobilelocation_mobileid_updatetype primary key (mobile_id, update_type),
	constraint fk_mobilelocation_mobileid foreign key (mobile_id) references mobile (id)
);

select addgeometrycolumn ('public', 'mobile_location', 'geom', 4326, 'POINT', 2);
select addgeometrycolumn ('public', 'mobile_location', 'section', 4326, 'LINESTRING', 2);

create unique index idx_mobilelocation_mobileid_updatetype on mobile_location (mobile_id, update_type);
create index idx_mobilelocation_geom on mobile_location using gist (geom);
create index idx_mobilelocation_section on mobile_location using gist (section);
cluster mobile_location using idx_mobilelocation_mobileid_updatetype;
