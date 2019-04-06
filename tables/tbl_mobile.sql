create table mobile (
	id sequence,
	organisation_id integer not null,
	name character varying (100) not null,
	timetable character varying (200),
	constraint pk_mobile_id primary key (id)
	constraint fk_mobile_organisation_id foreign key (organisation_id) references organisation(id)
);