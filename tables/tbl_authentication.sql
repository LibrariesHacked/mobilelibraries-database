create table authentication (
	id serial,
	organisation_id integer not null,
	domain character varying (200) not null,
	constraint pk_authentication_id primary key (id),
	constraint fk_authentication_organisation_id foreign key (organisation_id) references organisation(id)
);