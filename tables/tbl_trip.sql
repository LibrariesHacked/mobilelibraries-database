create table trip (
	id serial,
	origin_stop_id integer not null,
	destination_stop_id integer not null,
	distance integer,
	duration integer,
	constraint pk_trip_id primary key (id),
	constraint fk_trip_originstopid foreign key (origin_stop_id) references stop (id),
	constraint fk_trip_destinationstopid foreign key (destination_stop_id) references stop (id)
);

select addgeometrycolumn ('public', 'trip', 'geom', 4326, 'LINESTRING', 2);

create unique index idx_trip_id on trip (id);
create unique index idx_trip_originstopid_destinationstopid on trip (origin_stop_id, destination_stop_id);
create index idx_trip_originstopid on trip (origin_stop_id);
create index idx_trip_destinationstopid on trip (destination_stop_id);
create index idx_trip_geom on trip using gist (geom);
cluster trip using idx_trip_originstopid_destinationstopid;