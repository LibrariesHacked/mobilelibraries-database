create table route (
		id serial,
		mobile_id integer not null,
		name character varying (100) not null,
		week_day character varying (10),
		frequency character varying (50),
		start date not null,
		end date,
		timetable character varying (200),
		constraint pk_route_id primary key (id),
		constraint fk_route_mobile_id foreign key (mobile_id) references mobile(id)
);

select addgeometrycolumn ('public', 'stop', 'geom', 4326, 'MULTILINESTRING', 2);