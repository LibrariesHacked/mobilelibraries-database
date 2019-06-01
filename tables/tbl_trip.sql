create table trip (
	id serial,
	route_id integer,
	origin_stop_id integer,
	destination_stop_id integer,
	distance integer,
	duration integer,
	constraint pk_trip_id primary key (id),
	constraint fk_trip_stop_id_origin foreign key (origin_stop_id) references stop(id),
	constraint fk_trip_stop_id_destination foreign key (destination_stop_id) references stop(id)
);

select addgeometrycolumn ('public', 'trip', 'geom', 4326, 'MULTILINESTRING', 2);
