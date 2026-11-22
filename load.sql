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
select t.name, c.id, t.code, t.website, t.email, t.colour, t.logo from organisation_temp t join country c on c.name = t.country order by c.id, t.name;

drop table organisation_temp;

-- load Angus
\copy staging from 'data/angus.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Angus');
\copy trip_staging from 'data/routes/angus_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Angus');

-- load Bath and North East Somerset
\copy staging from 'data/bath_and_north_east_somerset.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Bath and North East Somerset');
\copy trip_staging from 'data/routes/bath_and_north_east_somerset_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Bath and North East Somerset');

-- load Bedford
\copy staging from 'data/bedford.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Bedford');
\copy trip_staging from 'data/routes/bedford_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Bedford');

-- load Cambridgeshire
\copy staging from 'data/cambridgeshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Cambridgeshire');
\copy trip_staging from 'data/routes/cambridgeshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Cambridgeshire');

-- load Carmarthenshire
\copy staging from 'data/carmarthenshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Carmarthenshire');
\copy trip_staging from 'data/routes/carmarthenshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Carmarthenshire');

-- load Cheshire East
\copy staging from 'data/cheshire_east.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Cheshire East');
\copy trip_staging from 'data/routes/cheshire_east_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Cheshire East');

-- load Cheshire West and Chester
\copy staging from 'data/cheshire_west_and_chester.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Cheshire West and Chester');
\copy trip_staging from 'data/routes/cheshire_west_and_chester_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Cheshire West and Chester');

-- load Conwy
\copy staging from 'data/conwy.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Conwy');
\copy trip_staging from 'data/routes/conwy_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Conwy');

-- load Cornwall
\copy staging from 'data/cornwall.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Cornwall');
\copy trip_staging from 'data/routes/cornwall_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Cornwall');

-- load County Durham
\copy staging from 'data/county_durham.csv' csv header;
select fn_load_stops_staging(organisation_name := 'County Durham');
\copy trip_staging from 'data/routes/county_durham_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'County Durham');

-- load Derbyshire
\copy staging from 'data/derbyshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Derbyshire');
\copy trip_staging from 'data/routes/derbyshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Derbyshire');

-- load East Ayrshire
\copy staging from 'data/east_ayrshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'East Ayrshire');
\copy trip_staging from 'data/routes/east_ayrshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'East Ayrshire');

-- load East Riding of Yorkshire
\copy staging from 'data/east_riding_of_yorkshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'East Riding of Yorkshire');
\copy trip_staging from 'data/routes/east_riding_of_yorkshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'East Riding of Yorkshire');

-- load Essex
\copy staging from 'data/essex.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Essex');
\copy trip_staging from 'data/routes/essex_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Essex');

-- load Fife
\copy staging from 'data/fife.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Fife');
\copy trip_staging from 'data/routes/fife_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Fife');

-- load Flintshire
\copy staging from 'data/flintshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Flintshire');
\copy trip_staging from 'data/routes/flintshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Flintshire');

-- load Highland
\copy staging from 'data/highland.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Highland');
\copy trip_staging from 'data/routes/highland_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Highland');

-- load Hillingdon
\copy staging from 'data/hillingdon.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Hillingdon');
\copy trip_staging from 'data/routes/hillingdon_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Hillingdon');

-- load Kent
\copy staging from 'data/kent.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Kent');
\copy trip_staging from 'data/routes/kent_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Kent');

-- load Lancashire
\copy staging from 'data/lancashire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Lancashire');
\copy trip_staging from 'data/routes/lancashire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Lancashire');

-- load Leicestershire
\copy staging from 'data/leicestershire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Leicestershire');
\copy trip_staging from 'data/routes/leicestershire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Leicestershire');

-- load LibrariesNI
\copy staging from 'data/librariesni.csv' csv header;
select fn_load_stops_staging(organisation_name := 'LibrariesNI');
\copy trip_staging from 'data/routes/librariesni_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'LibrariesNI');

-- load Lincolnshire
\copy staging from 'data/lincolnshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Lincolnshire');
\copy trip_staging from 'data/routes/lincolnshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Lincolnshire');

-- load Midlothian
\copy staging from 'data/midlothian.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Midlothian');
\copy trip_staging from 'data/routes/midlothian_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Midlothian');

-- load Neath Port Talbot
\copy staging from 'data/neath_port_talbot.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Neath Port Talbot');
\copy trip_staging from 'data/routes/neath_port_talbot_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Neath Port Talbot');

-- load Norfolk
\copy staging from 'data/norfolk.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Norfolk');
\copy trip_staging from 'data/routes/norfolk_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Norfolk');

-- load North Lincolnshire
\copy staging from 'data/north_lincolnshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'North Lincolnshire');
\copy trip_staging from 'data/routes/north_lincolnshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'North Lincolnshire');

-- load North Somerset
\copy staging from 'data/north_somerset.csv' csv header;
select fn_load_stops_staging(organisation_name := 'North Somerset');
\copy trip_staging from 'data/routes/north_somerset_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'North Somerset');

-- load North Yorkshire
\copy staging from 'data/north_yorkshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'North Yorkshire');
\copy trip_staging from 'data/routes/north_yorkshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'North Yorkshire');

-- load Northumberland
\copy staging from 'data/northumberland.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Northumberland');
\copy trip_staging from 'data/routes/northumberland_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Northumberland');

-- load Nottinghamshire
\copy staging from 'data/nottinghamshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Nottinghamshire');
\copy trip_staging from 'data/routes/nottinghamshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Nottinghamshire');

-- load Orkney Islands
\copy staging from 'data/orkney_islands.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Orkney Islands');
\copy trip_staging from 'data/routes/orkney_islands_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Orkney Islands');

-- load Pembrokeshire
\copy staging from 'data/pembrokeshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Pembrokeshire');
\copy trip_staging from 'data/routes/pembrokeshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Pembrokeshire');

-- load Perth and Kinross
\copy staging from 'data/perth_and_kinross.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Perth and Kinross');
\copy trip_staging from 'data/routes/perth_and_kinross_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Perth and Kinross');

-- load Portsmouth
\copy staging from 'data/portsmouth.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Portsmouth');
\copy trip_staging from 'data/routes/portsmouth_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Portsmouth');

-- load Shetland Islands
\copy staging from 'data/shetland_islands.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Shetland Islands');
\copy trip_staging from 'data/routes/shetland_islands_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Shetland Islands');

-- load Shropshire
\copy staging from 'data/shropshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Shropshire');
\copy trip_staging from 'data/routes/shropshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Shropshire');

-- load Somerset
\copy staging from 'data/somerset.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Somerset');
\copy trip_staging from 'data/routes/somerset_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Somerset');

-- load South Ayrshire
\copy staging from 'data/south_ayrshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'South Ayrshire');
\copy trip_staging from 'data/routes/south_ayrshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'South Ayrshire');

-- load Staffordshire
\copy staging from 'data/staffordshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Staffordshire');
\copy trip_staging from 'data/routes/staffordshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Staffordshire');

-- load Stirling
\copy staging from 'data/stirling.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Stirling');
\copy trip_staging from 'data/routes/stirling_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Stirling');

-- load Suffolk
\copy staging from 'data/suffolk.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Suffolk');
\copy trip_staging from 'data/routes/suffolk_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Suffolk');

-- load The Scottish Borders
\copy staging from 'data/the_scottish_borders.csv' csv header;
select fn_load_stops_staging(organisation_name := 'The Scottish Borders');
\copy trip_staging from 'data/routes/the_scottish_borders_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'The Scottish Borders');

-- load Warwickshire
\copy staging from 'data/warwickshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Warwickshire');
\copy trip_staging from 'data/routes/warwickshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Warwickshire');

-- load West Dunbartonshire
\copy staging from 'data/west_dunbartonshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'West Dunbartonshire');
\copy trip_staging from 'data/routes/west_dunbartonshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'West Dunbartonshire');

-- load Wiltshire
\copy staging from 'data/wiltshire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Wiltshire');
\copy trip_staging from 'data/routes/wiltshire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Wiltshire');

-- load Worcestershire
\copy staging from 'data/worcestershire.csv' csv header;
select fn_load_stops_staging(organisation_name := 'Worcestershire');
\copy trip_staging from 'data/routes/worcestershire_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'Worcestershire');

-- load York
\copy staging from 'data/york.csv' csv header;
select fn_load_stops_staging(organisation_name := 'York');
\copy trip_staging from 'data/routes/york_routes.csv' csv header;
select fn_load_trips_staging(organisation_name := 'York');

-- update schedule and location estimates
select fn_updates();

vacuum analyze;
