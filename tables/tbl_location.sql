create table location (
	id serial,
	mobile_id integer,
	update_type character varying (10),
	updated timestamp,
	constraint pk_location_id primary key (id),
	constraint fk_location_mobile_id foreign key (mobile_id) references mobile(id)
);

select addgeometrycolumn ('public', 'location', 'geom', 4326, 'POINT', 2);
