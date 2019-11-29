-- create temp table for orgs
create table organisation_temp (
	name character varying (200) not null,
	country character varying (200) not null,
	code character (9),
	website character varying (200),
	email character varying (200),
	domain character varying (200),
	colour character (7),
	logo character varying (200)
);

-- import organisations
\copy organisation_temp from 'data/organisations.csv' csv header;

-- import countries
insert into country(name)
select distinct country from organisation_temp order by country;

-- insert into organisation table
insert into organisation(name, country_id, code, website, email, colour, logo)
select t.name, c.id, t.code, t.website, t.email, t.colour, t.logo from organisation_temp t join country c on c.name = t.country;

-- now insert our authentication table
insert into authentication(organisation_id, domain)
select distinct o.id, t.domain from organisation_temp t
join organisation o on t.name = o.name
where t.domain is not null;

drop table organisation_temp;

-- load Aberdeenshire
\copy staging from 'data/aberdeenshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Aberdeenshire');
\copy trip_staging from 'data/aberdeenshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Aberdeenshire');

-- load Angus
\copy staging from 'data/angus.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Angus');
\copy trip_staging from 'data/angus_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Angus');

-- load Bath and North East Somerset 
\copy staging from 'data/bath_and_north_east_somerset.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Bath and North East Somerset');
\copy trip_staging from 'data/bath_and_north_east_somerset_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Bath and North East Somerset');

-- load Cambridgeshire
\copy staging from 'data/cambridgeshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Cambridgeshire');
\copy trip_staging from 'data/cambridgeshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Cambridgeshire');

-- load Essex
\copy staging from 'data/essex.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Essex');
\copy trip_staging from 'data/essex_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Essex');

-- load Norfolk
\copy staging from 'data/norfolk.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Norfolk');
\copy trip_staging from 'data/norfolk_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Norfolk');

-- load North Lincolnshire
\copy staging from 'data/north_lincolnshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'North Lincolnshire');
\copy trip_staging from 'data/north_lincolnshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'North Lincolnshire');

-- load North Somerset
\copy staging from 'data/north_somerset.csv' csv header;
select fn_load_stops_staging(organisation_name := 'North Somerset');
\copy trip_staging from 'data/north_somerset_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'North Somerset');

-- load Milton Keynes
\copy staging from 'data/milton_keynes.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Milton Keynes');
\copy trip_staging from 'data/milton_keynes_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Milton Keynes');

-- load Perth and Kinross
\copy staging from 'data/perth_and_kinross.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Perth and Kinross');
\copy trip_staging from 'data/perth_and_kinross_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Perth and Kinross');

-- load Portsmouth
\copy staging from 'data/portsmouth.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Portsmouth');
\copy trip_staging from 'data/portsmouth_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Portsmouth');

-- load Shropshire
\copy staging from 'data/shropshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Shropshire');
\copy trip_staging from 'data/shropshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Shropshire');

-- load Somerset
\copy staging from 'data/somerset.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Somerset');
\copy trip_staging from 'data/somerset_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Somerset');

-- load Warwickshire
\copy staging from 'data/warwickshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Warwickshire');
\copy trip_staging from 'data/warwickshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Warwickshire');

-- load West Berkshire
\copy staging from 'data/west_berkshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'West Berkshire');
\copy trip_staging from 'data/west_berkshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'West Berkshire');

-- load West Dunbartonshire
\copy staging from 'data/west_dunbartonshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'West Dunbartonshire');
\copy trip_staging from 'data/west_dunbartonshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'West Dunbartonshire');

-- load Wrexham
\copy staging from 'data/wrexham.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Wrexham');
\copy trip_staging from 'data/wrexham_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Wrexham');

-- load York
\copy staging from 'data/york.csv' csv header;
select fn_load_stops_staging(organisation_name := 'York');
\copy trip_staging from 'data/york_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'York');

vacuum analyze;