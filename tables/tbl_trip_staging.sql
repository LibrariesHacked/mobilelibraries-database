create table trip_staging (
	geom text not null,
	destination_stop character varying (200) not null,
	destination_stop_latitude numeric not null,
	destination_stop_longitude numeric not null,
	distance numeric,
	duration numeric,
	mobile character varying (200) not null,
	origin_stop character varying (200) not null,
	origin_stop_latitude numeric not null,
	origin_stop_longitude numeric not null,
	route character varying (200) not null
);