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

select addgeometrycolumn ('public', 'trip', 'geom', 4326, 'LINESTRING', 2);

create unique index idx_trip_id on trip (id);
create index idx_trip_routeid on trip (route_id);
create index idx_trip_originstopid on trip (origin_stop_id);
create index idx_trip_destinationstopid on trip (destination_stop_id);
create index idx_trip_geom on trip using gist (geom);
cluster stop using idx_stop_id;