create table organisation (
	id serial,
	name character varying (200) not null,
	code character (9),
	website character varying (200),
	email character varying (200),
	constraint pk_organisation_id primary key (id)
);