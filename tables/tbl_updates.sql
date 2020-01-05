create table updates (
	id serial,
	type character varying (200) not null,
	updated timestamp with time zone,
	constraint pk_updates_id primary key (id)
);

create unique index idx_updates_id on updates (id);
create index idx_updates_type_updated on updates (type, updated);
cluster updates using idx_updates_id;