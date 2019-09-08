-- create temp table for orgs
create table organisation_temp (
	name character varying (200) not null,
	code character (9),
	website character varying (200),
	email character varying (200),
	domain character varying (200)
);

-- import organisations
\copy organisation_temp from 'data/organisations.csv' csv header;

-- insert into proper table
insert into organisation(name, code, website, email)
select name, code, website, email from organisation_temp;

-- now insert our authentication table
insert into authentication(organisation_id, domain)
select distinct o.id, t.domain from organisation_temp t
join organisation o on t.name = o.name
where t.domain is not null;

drop table organisation_temp;

-- load Aberdeenshire
\copy staging from 'data/aberdeenshire.csv' csv header;
select fn_load_staging(organisation_name := 'Aberdeenshire');
\copy trip_staging from 'data/aberdeenshire_routes.csv' csv header;
select fn_load_trips_staging();

-- load Angus
\copy staging from 'data/angus.csv' csv header;
select fn_load_staging(organisation_name := 'Angus');
\copy trip_staging from 'data/angus_routes.csv' csv header;
select fn_load_trips_staging();

-- load Norfolk
\copy staging from 'data/norfolk.csv' csv header;
select fn_load_staging(organisation_name := 'Norfolk');
\copy trip_staging from 'data/norfolk_routes.csv' csv header;
select fn_load_trips_staging();

-- load North Somerset
\copy staging from 'data/north_somerset.csv' csv header;
select fn_load_staging(organisation_name := 'North Somerset');
\copy trip_staging from 'data/north_somerset_routes.csv' csv header;
select fn_load_trips_staging();

-- load Warwickshire
\copy staging from 'data/warwickshire.csv' csv header;
select fn_load_staging(organisation_name := 'Warwickshire');
\copy trip_staging from 'data/warwickshire_routes.csv' csv header;
select fn_load_trips_staging();

-- load West Dunbartonshire
\copy staging from 'data/west_dunbartonshire.csv' csv header;
select fn_load_staging(organisation_name := 'West Dunbartonshire');
\copy trip_staging from 'data/west_dunbartonshire_routes.csv' csv header;
select fn_load_trips_staging();

-- load Wrexham
\copy staging from 'data/wrexham.csv' csv header;
select fn_load_staging(organisation_name := 'Wrexham');
\copy trip_staging from 'data/wrexham_routes.csv' csv header;
select fn_load_trips_staging();

vacuum analyze;