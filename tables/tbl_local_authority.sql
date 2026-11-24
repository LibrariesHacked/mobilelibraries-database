create table local_authority (
	id serial,
	country_id integer not null,
	name character varying (200) not null,
	code character (9) not null,
	website character varying (200),
	email character varying (200),
	timetable character varying (200),
	colour character (7),
	logo character varying (200),
	constraint pk_localauthority_id primary key (id),
	constraint fk_localauthority_countryid foreign key (country_id) references country (id),
	constraint uq_localauthority_code unique (code),
	constraint ck_localauthority_code check (code ~ '^[ELMNSW][0-9]{8}$')
);

create unique index idx_localauthority_id on local_authority (id);
create unique index idx_localauthority_code on local_authority (code);
create index idx_localauthority_name on local_authority (name);
cluster local_authority using idx_localauthority_id;
