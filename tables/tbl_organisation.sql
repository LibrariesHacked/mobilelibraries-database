create table organisation (
	id serial,
	name character varying (200) not null,
	timetable character varying (200),
	constraint pk_organisation_id primary key (id)
);