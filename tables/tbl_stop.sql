create table stop (
	id serial,
	route_id integer,
	name character varying (100) not null,
	community character varying (100),
	address character varying (250),
	postcode character varying (10),
	constraint pk_stop_id primary key (id),
	constraint fk_stop_route_id foreign key (route_id) references route(id)
);

select addgeometrycolumn ('public', 'stop', 'geom', 4326, 'POINT', 2);