-- create the database
\i 'database/db_mobiles.sql';

-- switch to using the database
\c mobiles;

-- setup any extensions
\i 'database/db_extensions.sql';

-- setup any extensions
\i 'database/db_r_rule_functions.sql';

-- set client encoding
set client_encoding = 'UTF8';

-- create tables
\i 'tables/tbl_country.sql';
\i 'tables/tbl_organisation.sql';
\i 'tables/tbl_mobile.sql';
\i 'tables/tbl_route.sql';
\i 'tables/tbl_route_dates.sql';
\i 'tables/tbl_stop.sql';
\i 'tables/tbl_trip.sql';
\i 'tables/tbl_trip_staging.sql';
\i 'tables/tbl_location.sql';
\i 'tables/tbl_staging.sql';
\i 'tables/tbl_authentication.sql';
\i 'tables/tbl_updates.sql';

-- create views
\i 'views/vw_organisations.sql';
\i 'views/vw_mobiles.sql';
\i 'views/vw_routes.sql';
\i 'views/vw_stops.sql';
\i 'views/vw_stops_timetable.sql';
\i 'views/vw_trips.sql';
\i 'views/vw_schema.sql';
\i 'views/vw_mobiles_status.sql';
\i 'views/vw_mobiles_location.sql';

-- create functions
\i 'functions/fn_load_stops_staging.sql';
\i 'functions/fn_load_trips_staging.sql';
\i 'functions/fn_bbox.sql';
\i 'functions/fn_stops_mvt.sql';
\i 'functions/fn_trips_mvt.sql';
\i 'functions/fn_update_estimate_locations.sql';
\i 'functions/fn_update_route_dates.sql';
\i 'functions/fn_updates.sql';
\i 'functions/fn_estimate_location.sql';
\i 'functions/fn_estimate_route_section.sql';
\i 'functions/fn_mobiles_nearest.sql';

-- load in data
\i 'load.sql';