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

-- create views
\i 'views/vw_schema.sql';

-- create fucntions
\i 'functions/fn_loadstaging.sql';

-- load in data
\i 'load.sql';