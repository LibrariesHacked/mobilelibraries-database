create table authentication (
	id serial,
	organisation_id integer not null,
	domain character varying (200) not null,
	constraint pk_authentication_id primary key (id),
	constraint fk_authentication_organisationid foreign key (organisation_id) references organisation(id)
);

create unique index idx_authentication_id on authentication (id);
create index idx_authentication_organisationid on authentication (organisation_id);
cluster authentication using idx_authentication_id;