import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { after, before, test } from 'node:test';
import { PGlite } from '@electric-sql/pglite';
import { postgis } from '@electric-sql/pglite-postgis';

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const database = new PGlite({ extensions: { postgis } });

const readSql = relativePath => readFile(join(projectRoot, relativePath), 'utf8');
const query = async (sql, params = []) => (await database.query(sql, params)).rows;
const firstRow = async (sql, params = []) => (await query(sql, params))[0];

function closeTo(actual, expected, tolerance = 0.00001) {
    assert.ok(Math.abs(Number(actual) - expected) <= tolerance, `${actual} should be within ${tolerance} of ${expected}`);
}

async function installSqlFiles(paths) {
    for (const path of paths) {
        await database.exec(await readSql(path));
    }
}

before(async () => {
    await database.exec('CREATE EXTENSION IF NOT EXISTS postgis;');
    await database.exec(`
        CREATE SCHEMA test_support;
        CREATE FUNCTION test_support.mvt_transition(bigint, anyelement, text, integer, text)
        RETURNS bigint LANGUAGE sql IMMUTABLE AS 'SELECT $1 + 1';
        CREATE FUNCTION test_support.mvt_finalize(bigint)
        RETURNS bytea LANGUAGE sql IMMUTABLE AS 'SELECT convert_to($1::text, ''UTF8'')';
        CREATE FUNCTION test_support.st_asmvtgeom(geometry, geometry, integer, integer, boolean)
        RETURNS geometry LANGUAGE sql IMMUTABLE AS 'SELECT $1';
        CREATE AGGREGATE test_support.st_asmvt(anyelement, text, integer, text) (
            SFUNC = test_support.mvt_transition,
            STYPE = bigint,
            FINALFUNC = test_support.mvt_finalize,
            INITCOND = '0'
        );
    `);

    await installSqlFiles([
        'database/db_r_rule_functions.sql',
        'tables/tbl_country.sql',
        'tables/tbl_local_authority.sql',
        'tables/tbl_mobile.sql',
        'tables/tbl_route.sql',
        'tables/tbl_route_schedule.sql',
        'tables/tbl_stop.sql',
        'tables/tbl_route_stop.sql',
        'tables/tbl_trip.sql',
        'tables/tbl_trip_staging.sql',
        'tables/tbl_mobile_location.sql',
        'tables/tbl_stop_staging.sql',
        'tables/tbl_updates.sql',
        'views/vw_local_authorities.sql',
        'views/vw_organisations.sql',
        'views/vw_mobiles.sql',
        'views/vw_routes.sql',
        'views/vw_stops.sql',
        'views/vw_stops_timetable.sql',
        'views/vw_trips.sql',
        'views/vw_schema.sql',
        'views/vw_mobiles_status.sql',
        'views/vw_mobiles_location.sql',
        'functions/fn_load_stops_staging.sql',
        'functions/fn_load_trips_staging.sql',
        'functions/fn_bbox.sql',
        'functions/fn_stops_mvt.sql',
        'functions/fn_trips_mvt.sql',
        'functions/fn_update_estimate_locations.sql',
        'functions/fn_update_route_schedule.sql',
        'functions/fn_updates.sql',
        'functions/fn_estimate_location.sql',
        'functions/fn_estimate_route_section.sql',
        'functions/fn_mobiles_nearest.sql'
    ]);

    await database.exec(`
        INSERT INTO country (id, name) VALUES (1, 'England');
        INSERT INTO local_authority (id, country_id, name, code, colour, timetable)
        VALUES (1, 1, 'Sample Council', 'E12345678', '#123456', 'Council timetable');
        INSERT INTO mobile (id, local_authority_id, name, timetable)
        VALUES (1, 1, 'Sample Mobile', 'Mobile timetable');

        INSERT INTO route (id, mobile_id, name, frequency, timetable, "start", "end")
        VALUES (
            1, 1, 'Sample Route', 'FREQ=DAILY;COUNT=4', 'Route timetable',
            (now() AT TIME ZONE 'Europe/London')::date - 1,
            (now() AT TIME ZONE 'Europe/London')::date + 30
        );

        INSERT INTO stop (id, name, community, address, postcode, type, timetable, geom)
        VALUES
            (1, 'Origin Stop', 'Sample Community', '1 Sample Road', 'BA1 1AA', 'Public', '', ST_SetSRID(ST_MakePoint(-2.35, 51.38), 4326)),
            (2, 'Current Stop', 'Sample Community', '2 Sample Road', 'BA1 1AB', 'Public', 'Stop timetable', ST_SetSRID(ST_MakePoint(-2.34, 51.38), 4326)),
            (3, 'Destination Stop', 'Sample Community', '3 Sample Road', 'BA1 1AC', 'Public', NULL, ST_SetSRID(ST_MakePoint(-2.33, 51.38), 4326));

        WITH clock AS (
            SELECT
                now() AT TIME ZONE 'Europe/London' AS local_now,
                to_char((now() AT TIME ZONE 'Europe/London')::date, 'FMDay') AS weekday
        )
        INSERT INTO route_stop (route_id, stop_id, day, arrival, departure, exceptions)
        SELECT 1, stops.stop_id, clock.weekday,
               (clock.local_now::time + stops.arrival_offset)::time,
               (clock.local_now::time + stops.departure_offset)::time,
               ARRAY[]::text[]
        FROM clock
        CROSS JOIN (VALUES
            (1, interval '-3 minutes', interval '-2 minutes'),
            (2, interval '-1 minute', interval '1 minute'),
            (3, interval '2 minutes', interval '3 minutes')
        ) AS stops(stop_id, arrival_offset, departure_offset);

        INSERT INTO route_schedule (route_id, visit)
        VALUES (1, (now() AT TIME ZONE 'Europe/London')::date);

        INSERT INTO trip (id, origin_stop_id, destination_stop_id, distance, duration, geom)
        VALUES (
            1, 1, 3, 1500, 300,
            ST_GeomFromText('LINESTRING(-2.35 51.38,-2.34 51.38,-2.33 51.38)', 4326)
        );

        SELECT setval(pg_get_serial_sequence('country', 'id'), (SELECT max(id) FROM country));
        SELECT setval(pg_get_serial_sequence('local_authority', 'id'), (SELECT max(id) FROM local_authority));
        SELECT setval(pg_get_serial_sequence('mobile', 'id'), (SELECT max(id) FROM mobile));
        SELECT setval(pg_get_serial_sequence('route', 'id'), (SELECT max(id) FROM route));
        SELECT setval(pg_get_serial_sequence('stop', 'id'), (SELECT max(id) FROM stop));
        SELECT setval(pg_get_serial_sequence('trip', 'id'), (SELECT max(id) FROM trip));
    `);
});

after(async () => {
    await database.close();
});

test('all views return the expected sample timetable data', async t => {
    await t.test('vw_local_authorities and vw_organisations aggregate the authority', async () => {
        for (const view of ['vw_local_authorities', 'vw_organisations']) {
            const row = await firstRow(`SELECT * FROM ${view} WHERE id = 1`);
            assert.equal(row.name, 'Sample Council');
            assert.equal(row.number_mobiles, 1);
            assert.equal(row.number_routes, 1);
            assert.equal(row.number_stops, 3);
        }
    });

    await t.test('vw_mobiles and vw_routes expose service identifiers and stop counts', async () => {
        const mobile = await firstRow('SELECT * FROM vw_mobiles WHERE id = 1');
        assert.equal(mobile.service_code.trim(), 'E12345678');
        assert.equal(mobile.name, 'Sample Mobile');
        assert.equal(mobile.number_routes, 1);
        assert.equal(mobile.number_stops, 3);

        const route = await firstRow('SELECT * FROM vw_routes WHERE id = 1');
        assert.equal(route.name, 'Sample Route');
        assert.equal(route.mobile_id, 1);
        assert.equal(route.number_stops, 3);
    });

    await t.test('vw_stops and vw_stops_timetable expose stop details and visits', async () => {
        const stop = await firstRow("SELECT * FROM vw_stops WHERE name = 'Current Stop'");
        assert.deepEqual(stop.route_names, ['Sample Route']);
        assert.deepEqual(stop.mobile_names, ['Sample Mobile']);
        assert.equal(stop.organisation_colour.trim(), '#123456');
        assert.equal(stop.timetable, 'Stop timetable');
        assert.equal(stop.route_schedule.length, 1);
        assert.equal(stop.longitude, -2.34);

        const timetable = await firstRow('SELECT * FROM vw_stops_timetable WHERE id = 2');
        assert.equal(timetable.mobile_id, 1);
        assert.equal(timetable.route_id, 1);
        const today = await firstRow("SELECT to_char((now() AT TIME ZONE 'Europe/London')::date, 'FMDay') AS weekday");
        assert.equal(timetable.day, today.weekday);
    });

    await t.test('vw_trips and vw_schema expose joined and compatibility fields', async () => {
        const trip = await firstRow('SELECT * FROM vw_trips WHERE id = 1');
        assert.equal(trip.origin_stop_name, 'Origin Stop');
        assert.equal(trip.destination_stop_name, 'Destination Stop');
        assert.equal(trip.distance, 1500);
        assert.equal(trip.route_line.type, 'LineString');

        const schema = await firstRow('SELECT * FROM vw_schema WHERE stop = $1', ['Current Stop']);
        assert.equal(schema.local_authority_code.trim(), 'E12345678');
        assert.equal(schema.mobile_name, 'Sample Mobile');
        assert.equal(schema.route, 'Sample Route');
        assert.equal(schema.timetable, 'Stop timetable');
        assert.equal(schema['Stop'], 'Current Stop');
        assert.equal(schema['GeoX'], -2.34);
    });

    await t.test('vw_mobiles_status identifies the active stop and adjacent stops', async () => {
        const status = await firstRow('SELECT * FROM vw_mobiles_status WHERE mobile_id = 1');
        const timeAllowsAdjacentStops = (await firstRow(`
            SELECT local_now::time > time '00:05' AND local_now::time < time '23:55' AS active
            FROM (SELECT now() AT TIME ZONE 'Europe/London' AS local_now) clock
        `)).active;
        if (timeAllowsAdjacentStops) {
            assert.ok(status, 'sample route should be active at the current local time');
            assert.equal(status.previous_stop_id, 1);
            assert.equal(status.current_stop_id, 2);
            assert.equal(status.next_stop_id, 3);
        }
    });

    await t.test('vw_mobiles_location falls back to the current stop before a location update', async () => {
        const status = await firstRow('SELECT * FROM vw_mobiles_status WHERE mobile_id = 1');
        const location = await firstRow('SELECT * FROM vw_mobiles_location WHERE mobile_id = 1');
        if (status) {
            assert.equal(location.current_stop_id, status.current_stop_id);
            assert.equal(location.geox, -2.34);
            assert.equal(location.geoy, 51.38);
            assert.equal(location.route_section, null);
        } else {
            assert.equal(location, undefined);
        }
    });
});

test('recurrence-rule functions calculate and filter sample occurrences', async t => {
    await t.test('parse_rrule_parts parses frequency, count, interval, and weekdays', async () => {
        const row = await firstRow(`
            SELECT (parts).freq AS freq, (parts).count AS count, (parts).interval AS interval,
                   (parts).byday AS byday
            FROM (SELECT parse_rrule_parts('2026-06-01 09:00+00', 'FREQ=WEEKLY;COUNT=5;INTERVAL=2;BYDAY=MO,FR') AS parts) parsed
        `);
        assert.equal(row.freq, 'WEEKLY');
        assert.equal(row.count, 5);
        assert.equal(row.interval, 2);
        assert.deepEqual(row.byday, ['MO', 'FR']);
    });

    await t.test('month and week date-set helpers return the requested days', async () => {
        const mondays = await query("SELECT d::date AS day FROM rrule_month_byday_set('2026-01-01 09:00+00', ARRAY['MO']) d");
        assert.equal(mondays.length, 4);
        assert.equal(mondays[0].day.toISOString().slice(0, 10), '2026-01-05');

        const monthdays = await query("SELECT d::date AS day FROM rrule_month_bymonthday_set('2026-01-15 09:00+00', ARRAY[1, -1]) d");
        assert.deepEqual(monthdays.map(row => row.day.toISOString().slice(0, 10)), ['2026-01-01', '2026-01-31']);

        const weekdays = await query("SELECT d::date AS day FROM rrule_week_byday_set('2026-06-03 09:00+00', ARRAY['MO', 'FR']) d");
        assert.deepEqual(weekdays.map(row => row.day.toISOString().slice(0, 10)), ['2026-06-01', '2026-06-05']);
    });

    await t.test('exception and BY* predicates accept matching input and reject non-matches', async () => {
        const row = await firstRow(`
            SELECT
                event_has_exceptions($1) AS has_exception,
                test_byday_rule('2026-06-01 09:00+00', ARRAY['MO']) AS byday_match,
                test_byday_rule('2026-06-01 09:00+00', ARRAY['TU']) AS byday_miss,
                test_bymonth_rule('2026-06-01 09:00+00', ARRAY[6]) AS bymonth_match,
                test_bymonthday_rule('2026-06-01 09:00+00', ARRAY[1]) AS bymonthday_match,
                test_byyearday_rule('2026-06-01 09:00+00', ARRAY[152]) AS byyearday_match
        `, ['\nRECURRENCE-ID:20260601']);
        assert.equal(row.has_exception, true);
        assert.equal(row.byday_match, true);
        assert.equal(row.byday_miss, false);
        assert.equal(row.bymonth_match, true);
        assert.equal(row.bymonthday_match, true);
        assert.equal(row.byyearday_match, true);
        assert.equal((await firstRow("SELECT event_has_exceptions('no exception') AS result")).result, false);
    });

    await t.test('rrule_bysetpos_filter selects a cursor position', async () => {
        await database.exec(`
            BEGIN;
            DECLARE rrule_test_cursor SCROLL CURSOR FOR
                SELECT value::timestamptz FROM (VALUES
                    ('2026-06-01 09:00+00'), ('2026-06-02 09:00+00'), ('2026-06-03 09:00+00')
                ) AS dates(value);
        `);
        const rows = await query("SELECT d::date AS day FROM rrule_bysetpos_filter('rrule_test_cursor', ARRAY[2]) d");
        await database.exec('COMMIT;');
        assert.equal(rows.length, 1);
        assert.equal(rows[0].day.toISOString().slice(0, 10), '2026-06-02');
    });

    await t.test('daily, weekly, monthly, and yearly set functions produce occurrences', async () => {
        const daily = await query(`
            SELECT d::date AS day FROM daily_set(
                '2026-06-01 09:00+00',
                parse_rrule_parts('2026-06-01 09:00+00', 'FREQ=DAILY;BYDAY=MO')
            ) d
        `);
        assert.equal(daily.length, 1);

        const weekly = await query(`
            SELECT d::date AS day FROM weekly_set(
                '2026-06-03 09:00+00',
                parse_rrule_parts('2026-06-03 09:00+00', 'FREQ=WEEKLY;BYDAY=MO,FR')
            ) d
        `);
        assert.deepEqual(weekly.map(row => row.day.toISOString().slice(0, 10)), ['2026-06-01', '2026-06-05']);

        const monthly = await query(`
            SELECT d::date AS day FROM monthly_set(
                '2026-06-01 09:00+00',
                parse_rrule_parts('2026-06-01 09:00+00', 'FREQ=MONTHLY;BYMONTHDAY=15')
            ) d
        `);
        assert.deepEqual(monthly.map(row => row.day.toISOString().slice(0, 10)), ['2026-06-15']);

        const yearlyMonth = await query(`
            SELECT d::date AS day FROM rrule_yearly_bymonth_set(
                '2026-01-01 09:00+00',
                parse_rrule_parts('2026-01-01 09:00+00', 'FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1')
            ) d
        `);
        assert.deepEqual(yearlyMonth.map(row => row.day.toISOString().slice(0, 10)), ['2026-01-01']);

        const yearly = await query(`
            SELECT d::date AS day FROM yearly_set(
                '2026-01-01 09:00+00',
                parse_rrule_parts('2026-01-01 09:00+00', 'FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1')
            ) d
        `);
        assert.deepEqual(yearly.map(row => row.day.toISOString().slice(0, 10)), ['2026-01-01']);
    });

    await t.test('range, convenience, overlap, composite-event, and interval functions work', async () => {
        const range = await query(`
            SELECT d::date AS day FROM rrule_event_instances_range(
                '2026-01-01 09:00+00', 'FREQ=DAILY;COUNT=3',
                '2026-01-01 00:00+00', '2026-01-05 00:00+00', 10
            ) d
        `);
        assert.equal(range.length, 3);

        const events = await query("SELECT d::date AS day FROM event_instances('2026-01-01 09:00+00', 'FREQ=DAILY;COUNT=3') d");
        assert.equal(events.length, 3);

        const overlap = await firstRow(`
            SELECT
                rrule_event_overlaps('2026-01-01 09:00+00', '2026-01-01 10:00+00', NULL, '2026-01-01 09:30+00', '2026-01-01 11:00+00') AS overlaps,
                rrule_event_overlaps('2026-01-01 09:00+00', NULL, NULL, '2026-01-02 00:00+00', '2026-01-03 00:00+00') AS misses,
                rrule_event_overlaps(NULL, NULL, NULL, NULL, NULL) AS null_start
        `);
        assert.equal(overlap.overlaps, true);
        assert.equal(overlap.misses, false);
        assert.equal(overlap.null_start, null);

        const compositeEvents = await query("SELECT dtstart, rrule, instance FROM rrule_event_instances('2026-01-01 09:00+00', 'FREQ=DAILY;COUNT=3')");
        assert.equal(compositeEvents.length, 3);
        assert.equal(compositeEvents[0].rrule, 'FREQ=DAILY;COUNT=3');

        const interval = await firstRow("SELECT icalendar_interval_to_SQL('PT1H30M')::text AS value");
        assert.equal(interval.value, '01:30:00');
    });
});

test('PostGIS utility and location functions operate on sample geometries', async t => {
    await t.test('fn_bbox creates the expected Web Mercator tile envelope', async () => {
        const bounds = await firstRow('SELECT ST_XMin(fn_bbox(1, 1, 1)) AS xmin, ST_XMax(fn_bbox(1, 1, 1)) AS xmax, ST_YMin(fn_bbox(1, 1, 1)) AS ymin, ST_YMax(fn_bbox(1, 1, 1)) AS ymax');
        closeTo(bounds.xmin, 0);
        closeTo(bounds.xmax, 20037508.34, 0.01);
        closeTo(bounds.ymin, -20037508.34, 0.01);
        closeTo(bounds.ymax, 0);
    });

    await t.test('fn_estimate_location handles null, invalid duration, and in-progress trips', async () => {
        const row = await firstRow(`
            SELECT
                fn_estimate_location(NULL, now()::timestamp, now()::timestamp) IS NULL AS null_trip,
                ST_X(fn_estimate_location(
                    ST_GeomFromText('LINESTRING(-2.35 51.38,-2.33 51.38)', 4326),
                    now()::timestamp, now()::timestamp
                )) AS zero_duration_x,
                ST_X(fn_estimate_location(
                    ST_GeomFromText('LINESTRING(-2.35 51.38,-2.33 51.38)', 4326),
                    (now() AT TIME ZONE 'Europe/London') - interval '30 seconds',
                    (now() AT TIME ZONE 'Europe/London') + interval '30 seconds'
                )) AS midway_x
        `);
        assert.equal(row.null_trip, true);
        closeTo(row.zero_duration_x, -2.35);
        closeTo(row.midway_x, -2.34, 0.001);
    });

    await t.test('fn_estimate_route_section handles null, invalid duration, and line sections', async () => {
        const row = await firstRow(`
            SELECT
                fn_estimate_route_section(NULL, now()::timestamp, now()::timestamp, 30, 5) IS NULL AS null_trip,
                ST_X(fn_estimate_route_section(
                    ST_GeomFromText('LINESTRING(-2.35 51.38,-2.33 51.38)', 4326),
                    now()::timestamp, now()::timestamp, 30, 5
                )) AS zero_duration_x,
                ST_NPoints(fn_estimate_route_section(
                    ST_GeomFromText('LINESTRING(-2.35 51.38,-2.33 51.38)', 4326),
                    (now() AT TIME ZONE 'Europe/London') - interval '60 seconds',
                    (now() AT TIME ZONE 'Europe/London') + interval '60 seconds', 20, 5
                )) AS section_points
        `);
        assert.equal(row.null_trip, true);
        closeTo(row.zero_duration_x, -2.35);
        assert.ok(row.section_points > 1);
    });

    await t.test('fn_mobiles_nearest returns the closest routed mobile', async () => {
        const nearest = await firstRow('SELECT * FROM fn_mobiles_nearest(-2.35, 51.38, 500)');
        assert.equal(nearest.mobile_id, 1);
        assert.equal(nearest.stop_id, 1);
        assert.equal(nearest.stop_name, 'Origin Stop');
        assert.equal(nearest.stop_distance, 0);
    });

    await t.test('MVT functions select the stops and trips in a tile', async () => {
        await database.exec('SET search_path = test_support, public;');
        try {
            const tiles = await firstRow(`
                SELECT convert_from(fn_stops_mvt(0, 0, 0), 'UTF8') AS stops,
                       convert_from(fn_trips_mvt(0, 0, 0), 'UTF8') AS trips
            `);
            assert.equal(tiles.stops, '3');
            assert.equal(tiles.trips, '1');
        } finally {
            await database.exec('RESET search_path;');
        }
    });
});

test('staging loaders insert matched rows and preserve unmatched trip staging', async t => {
    await t.test('fn_load_stops_staging rejects an unknown authority without discarding staged rows', async () => {
        await database.exec(`
            INSERT INTO stop_staging (
                local_authority, local_authority_code, mobile_name, route, stop, geox, geoy,
                day, type, arrival, departure, frequency, "start"
            ) VALUES (
                'Missing Council', 'E12345678', 'Unused Mobile', 'Unused Route', 'Unused Stop',
                -2.30, 51.40, 'Monday', 'Public', '10:00', '10:05', 'FREQ=DAILY;COUNT=1', current_date
            );
        `);
        await assert.rejects(() => query("SELECT fn_load_stops_staging('Missing Council')"), /Local authority not found/);
        assert.equal((await firstRow('SELECT count(*)::int AS count FROM stop_staging')).count, 1);
        await database.exec('DELETE FROM stop_staging;');
    });

    await t.test('fn_load_stops_staging loads mobile, route, stop, and route-stop data', async () => {
        await database.exec(`
            WITH clock AS (
                SELECT to_char((now() AT TIME ZONE 'Europe/London')::date, 'FMDay') AS weekday
            )
            INSERT INTO stop_staging (
                local_authority, local_authority_code, mobile_name, route, community, stop,
                address, postcode, geox, geoy, day, type, arrival, departure, frequency,
                "start", "end", exceptions, timetable
            )
            SELECT 'Sample Council', 'E12345678', 'Staging Mobile', 'Staging Route',
                   'Staging Community', 'Staging Stop', '4 Sample Road', 'BA1 1AD',
                   -2.30, 51.40, weekday, 'Public', '12:00', '12:05',
                   'FREQ=DAILY;COUNT=4', (now() AT TIME ZONE 'Europe/London')::date,
                   (now() AT TIME ZONE 'Europe/London')::date + 30, '', 'Staging timetable'
            FROM clock;
            SELECT fn_load_stops_staging('E12345678');
        `);

        assert.equal((await firstRow("SELECT count(*)::int AS count FROM mobile WHERE name = 'Staging Mobile'")).count, 1);
        assert.equal((await firstRow("SELECT count(*)::int AS count FROM route WHERE name = 'Staging Route'")).count, 1);
        assert.equal((await firstRow("SELECT count(*)::int AS count FROM stop WHERE name = 'Staging Stop'")).count, 1);
        assert.equal((await firstRow("SELECT count(*)::int AS count FROM route_stop rs JOIN route r ON r.id = rs.route_id WHERE r.name = 'Staging Route'")).count, 1);
        assert.equal((await firstRow('SELECT count(*)::int AS count FROM stop_staging')).count, 0);
    });

    await t.test('fn_load_trips_staging loads matching trips and clears staging', async () => {
        await database.exec(`
            INSERT INTO stop (name, geom) VALUES
                ('Trip Staging Origin', ST_SetSRID(ST_MakePoint(-2.32, 51.39), 4326)),
                ('Trip Staging Destination', ST_SetSRID(ST_MakePoint(-2.31, 51.39), 4326));
            INSERT INTO trip_staging (
                geom, destination_stop, destination_stop_latitude, destination_stop_longitude,
                distance, duration, mobile, origin_stop, origin_stop_latitude,
                origin_stop_longitude, route
            ) VALUES (
                'LINESTRING(-2.32 51.39,-2.31 51.39)', 'Trip Staging Destination', 51.39, -2.31,
                750, 180, 'Sample Mobile', 'Trip Staging Origin', 51.39, -2.32, 'Sample Route'
            );
            SELECT fn_load_trips_staging('Sample Council');
        `);

        const trip = await firstRow(`
            SELECT t.distance, os.name AS origin, ds.name AS destination
            FROM trip t
            JOIN stop os ON os.id = t.origin_stop_id
            JOIN stop ds ON ds.id = t.destination_stop_id
            WHERE os.name = 'Trip Staging Origin'
        `);
        assert.equal(trip.distance, 750);
        assert.equal(trip.origin, 'Trip Staging Origin');
        assert.equal(trip.destination, 'Trip Staging Destination');
        assert.equal((await firstRow('SELECT count(*)::int AS count FROM trip_staging')).count, 0);
    });
});

test('schedule and location update functions persist derived records', async t => {
    let shouldCreateLocation = false;
    await t.test('fn_update_route_schedule creates recurrence dates and update timestamp', async () => {
        await query('SELECT fn_update_route_schedule()');
        const row = await firstRow('SELECT count(*)::int AS visits FROM route_schedule WHERE route_id = 1');
        assert.equal(row.visits, 3);
        assert.ok((await firstRow("SELECT updated FROM updates WHERE type = 'route_schedule'")).updated);
    });

    await t.test('fn_update_estimate_locations writes an estimated point and route section', async () => {
        shouldCreateLocation = (await firstRow(`
            SELECT EXISTS (
                SELECT 1
                FROM vw_mobiles_status
                WHERE mobile_id = 1
                  AND previous_stop_id IS NOT NULL
                  AND next_stop_id IS NOT NULL
                  AND route_start < (now() AT TIME ZONE 'Europe/London')::time
                  AND route_finish > (now() AT TIME ZONE 'Europe/London')::time
            ) AS active
        `)).active;
        await query('SELECT fn_update_estimate_locations()');
        const location = await firstRow("SELECT * FROM mobile_location WHERE mobile_id = 1 AND update_type = 'Estimated'");
        assert.ok((await firstRow("SELECT updated FROM updates WHERE type = 'estimated_location'")).updated);

        if (shouldCreateLocation) {
            assert.ok(location);
            assert.ok(location.geom);
            assert.ok(location.section);
            assert.equal(location.section_interval, 60);

            const view = await firstRow('SELECT * FROM vw_mobiles_location WHERE mobile_id = 1');
            assert.ok(view.route_section);
            closeTo(view.geox, -2.34, 0.005);
        } else {
            assert.equal(location, undefined);
        }
    });

    await t.test('fn_updates safely runs both update functions when their records are current', async () => {
        await query('SELECT fn_updates()');
        assert.equal((await firstRow('SELECT count(*)::int AS count FROM updates')).count, 2);
        assert.equal((await firstRow("SELECT count(*)::int AS count FROM mobile_location WHERE update_type = 'Estimated'")).count, Number(shouldCreateLocation));
    });
});

test('fn_load_trips_staging raises instead of clearing unmatched staging on an empty trip table', async () => {
    await database.exec(`
        TRUNCATE trip RESTART IDENTITY;
        INSERT INTO trip_staging (
            geom, destination_stop, destination_stop_latitude, destination_stop_longitude,
            distance, duration, mobile, origin_stop, origin_stop_latitude,
            origin_stop_longitude, route
        ) VALUES (
            'LINESTRING(-2.30 51.40,-2.29 51.40)', 'No matching destination', 51.40, -2.29,
            100, 30, 'No matching mobile', 'No matching origin', 51.40, -2.30, 'No matching route'
        );
    `);

    await assert.rejects(
        () => query("SELECT fn_load_trips_staging('Sample Council')"),
        /No trips were loaded/);
    assert.equal((await firstRow('SELECT count(*)::int AS count FROM trip')).count, 0);
    assert.equal((await firstRow('SELECT count(*)::int AS count FROM trip_staging')).count, 1);
});

test('fn_load_trips_staging matches routes when the staged mobile label is stale', async () => {
    await database.exec(`
        DELETE FROM trip_staging;
        TRUNCATE trip RESTART IDENTITY;
        INSERT INTO trip_staging (
            geom, destination_stop, destination_stop_latitude, destination_stop_longitude,
            distance, duration, mobile, origin_stop, origin_stop_latitude,
            origin_stop_longitude, route
        ) VALUES (
            'LINESTRING(-2.35 51.38,-2.33 51.38)', 'Destination Stop', 51.38, -2.33,
            100, 60, 'Mobile', 'Origin Stop', 51.38, -2.35, 'Sample Route'
        );
    `);

    await query("SELECT fn_load_trips_staging('Sample Council')");

    const trip = await firstRow(`
        SELECT t.distance, os.name AS origin, ds.name AS destination
        FROM trip t
        JOIN stop os ON os.id = t.origin_stop_id
        JOIN stop ds ON ds.id = t.destination_stop_id
    `);
    assert.equal(trip.distance, 100);
    assert.equal(trip.origin, 'Origin Stop');
    assert.equal(trip.destination, 'Destination Stop');
    assert.equal((await firstRow('SELECT count(*)::int AS count FROM trip_staging')).count, 0);
});

test('fn_load_trips_staging skips one-point geometries without blocking valid trips', async () => {
    await database.exec(`
        DELETE FROM trip_staging;
        TRUNCATE trip RESTART IDENTITY;
        INSERT INTO trip_staging (
            geom, destination_stop, destination_stop_latitude, destination_stop_longitude,
            distance, duration, mobile, origin_stop, origin_stop_latitude,
            origin_stop_longitude, route
        ) VALUES
            (
                'LINESTRING (-2.35 51.38)', 'Destination Stop', 51.38, -2.33,
                100, 60, 'Sample Mobile', 'Origin Stop', 51.38, -2.35, 'Sample Route'
            ),
            (
                'LINESTRING (-2.35 51.38,-2.34 51.38)', 'Current Stop', 51.38, -2.34,
                50, 30, 'Sample Mobile', 'Origin Stop', 51.38, -2.35, 'Sample Route'
            );
    `);

    await query("SELECT fn_load_trips_staging('Sample Council')");

    assert.equal((await firstRow('SELECT count(*)::int AS count FROM trip')).count, 1);
    assert.equal((await firstRow('SELECT count(*)::int AS count FROM trip_staging')).count, 0);
});