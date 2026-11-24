-- =============================================================================
-- Atomic transactional refresh of mobile libraries database
-- =============================================================================
\set ON_ERROR_STOP on
set client_encoding = 'UTF8';

begin;

-- Truncate existing data tables (cascade handles dependent route_stop, mobile_location, route_schedule, trip)
truncate table route_stop, trip, route_schedule, mobile_location, route, stop, mobile, local_authority, country, updates restart identity cascade;

-- Load latest data from load.sql
\i 'load.sql';

commit;
