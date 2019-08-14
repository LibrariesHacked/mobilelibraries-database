create table mobile (
	id serial,
	organisation_id integer not null,
	name character varying (200) not null,
	timetable character varying (200),
	constraint pk_mobile_id primary key (id),
	constraint fk_mobile_organisation_id foreign key (organisation_id) references organisation(id)
);

create unique index idx_mobile_id on mobile (id);
create index idx_mobile_organisationid on mobile (organisation_id);
cluster mobile using idx_mobile_id;