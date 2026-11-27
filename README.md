# Mobile libraries database

[![Sync data and update database](https://github.com/LibrariesHacked/mobilelibraries-database/actions/workflows/sync_and_update.yml/badge.svg)](https://github.com/LibrariesHacked/mobilelibraries-database/actions/workflows/sync_and_update.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This is the PostgreSQL and PostGIS database for the [mobile library project](https://blog.librarydata.uk/mobile-library-data-project). It stores timetables, stops, driving routes, and estimated live vehicle locations across the UK.

Upstream data is maintained in the [LibrariesHacked/mobilelibraries-data](https://github.com/LibrariesHacked/mobilelibraries-data) repository.

## Getting Started

### Prerequisites

To run this database you will need PostgreSQL (version 10+) with the PostGIS extension installed.

- [PostgreSQL](https://www.postgresql.org/)
- [PostGIS](https://postgis.net/)

### Initial Database Creation

To initialize a brand new database and load all tables, views, functions, and data:

```console
psql --set=sslmode=require -f create.sql -h <host> -p 5432 -U <username> postgres
```

On Windows, a template script is provided in `create.bat.template`.

### Updating an Existing Database

To update an existing live database with the latest stops, routes, and schedule estimates transactionally without recreating schema or views:

```console
psql --set=sslmode=require -f update.sql -h <host> -p 5432 -U <username> mobiles
```

On Windows, a template script is provided in `update.bat.template`.

## Automated SQL Tests

The views and SQL functions can be tested locally without installing or connecting to a PostgreSQL server. The test suite runs the repository's schema, views, and functions in an in-memory PostgreSQL database powered by PGlite, with its PostGIS extension enabled, and loads a small sample timetable.

Install Node.js 20 or later, then run:

```console
npm ci
npm test
```

The PostGIS extension for PGlite is experimental. Its build lacks protobuf-c support, so MVT tests replace the tile-encoding aggregate with a counter and the MVT clipping helper with a pass-through function; they verify wrapper filtering and feature selection but not clipping or encoded vector-tile bytes. These tests provide fast SQL and data-behavior checks, but they do not replace validation against the production PostgreSQL/PostGIS versions.

## Data Synchronization

Data files in `data/` and `data/routes/` are synced from [LibrariesHacked/mobilelibraries-data](https://github.com/LibrariesHacked/mobilelibraries-data).

To manually sync data locally and regenerate `load.sql` and `update.sql`:

```bash
# Automatically detects sibling ../mobilelibraries-data or clones from GitHub
python scripts/sync_data.py

# Or specify a custom source directory
python scripts/sync_data.py --source /path/to/mobilelibraries-data
```

The sync script automatically:
1. Copies all 48 authority stop datasets into `data/`.
2. Copies all corresponding route road geometries into `data/routes/`.
3. Synchronises `data/organisations.csv` with official service and GSS codes.
4. Generates an alphabetical, deterministic `load.sql` referencing all active services.
5. Generates the atomic `update.sql` transaction script.

## Automated Nightly Sync and Database Update

A GitHub Actions workflow is configured in `.github/workflows/sync_and_update.yml`.

- **Schedule:** Runs nightly at 02:00 UTC.
- **Manual trigger:** Can be triggered at any time via `workflow_dispatch` in the GitHub Actions tab.
- **Webhook dispatch:** Can be triggered via `repository_dispatch` (event type `mobilelibraries_data_updated`) from `mobilelibraries-data`.
- **Workflow actions:**
  1. Clones the latest data from `LibrariesHacked/mobilelibraries-data`.
  2. Runs `scripts/sync_data.py` to sync datasets and regenerate `load.sql`.
  3. Commits and pushes any changed data back to this repository.
  4. Connects to PostgreSQL via `psql` and executes `update.sql` to refresh the live database.

### Configuring Secrets for Automated Updates

To enable the automated database update step in GitHub Actions, add these repository secrets:

- `PGHOST`: Database server hostname (e.g. `librarieshacked.postgres.database.azure.com`)
- `PGUSER`: Database username
- `PGPASSWORD`: Database user password
- `PGDATABASE`: Database name (defaults to `mobiles`)
- `PGPORT`: Port number (defaults to `5432`)

## Authors

- **Dave Rowe** - *Initial work* - [Libraries Hacked](https://github.com/DaveBathnes)

See the list of [contributors](https://github.com/librarieshacked/mobilelibraries-database/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- All UK mobile library services and operators.
