create table organisation (
	id serial,
	name character varying (200) not null,
	code character (9),
	website character varying (200),
	email character varying (200),
	timetable character varying (200),
	colour character (7),
	logo character varying (200),
	constraint pk_organisation_id primary key (id)
);

create unique index idx_organisation_id on organisation (id);
cluster organisation using idx_organisation_id;