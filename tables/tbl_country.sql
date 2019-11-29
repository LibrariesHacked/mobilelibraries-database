create table country (
	id serial,
	name character varying (200) not null,
	constraint pk_country_id primary key (id)
);

create unique index idx_country_id on country (id);
cluster country using idx_country_id;