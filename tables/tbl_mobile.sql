create table mobile (
	id serial,
	local_authority_id integer not null,
	name character varying (200) not null,
	timetable character varying (200),
	constraint pk_mobile_id primary key (id),
	constraint fk_mobile_localauthorityid foreign key (local_authority_id) references local_authority (id)
);

create unique index idx_mobile_id on mobile (id);
create index idx_mobile_localauthorityid on mobile (local_authority_id);
cluster mobile using idx_mobile_id;
