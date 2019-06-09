create table trip_staging (
	mobile character varying (200) not null,
	route character varying (200) not null,
	origin_stop character varying (200) not null,
	destination_stop character varying (200) not null,
	geom text
);