create table updates (
	type character varying (200) not null,
	updated timestamp with time zone,
	constraint pk_updates_type primary key (type)
);

create unique index idx_updates_type_updated on updates (type, updated);
cluster updates using idx_updates_type_updated;