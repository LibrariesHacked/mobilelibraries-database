-- create the database
\i 'database/db_mobiles.sql';

-- switch to using the database
\c mobiles;

-- setup any extensions
\i 'database/db_extensions.sql';

-- set client encoding
set client_encoding = 'UTF8';

-- create tables
\i 'tables/tbl_organisation.sql';
\i 'tables/tbl_mobile.sql';
\i 'tables/tbl_route.sql';
\i 'tables/tbl_stop.sql';
\i 'tables/tbl_staging.sql';
\i 'tables/tbl_authentication.sql';

-- create views
\i 'views/vw_organisations.sql';
\i 'views/vw_mobiles.sql';
\i 'views/vw_routes.sql';
\i 'views/vw_stops.sql';
\i 'views/vw_schema.sql';

-- create functions
\i 'functions/fn_loadstaging.sql';

-- load in data
\i 'load.sql';