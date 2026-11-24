#!/usr/bin/env python3
"""
Sync Mobile Library Data from LibrariesHacked/mobilelibraries-data.

This script:
1. Locates or downloads the latest data from LibrariesHacked/mobilelibraries-data.
2. Updates authority stops CSVs in data/ and routes CSVs in data/routes/.
3. Synchronises data/organisations.csv with official service metadata.
4. Automatically regenerates load.sql and update.sql for all active authorities.
"""

import argparse
import csv
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = REPO_ROOT / 'data'
ROUTES_DIR = DATA_DIR / 'routes'
ORGS_CSV = DATA_DIR / 'organisations.csv'
LOCAL_AUTHORITIES_CSV = DATA_DIR / 'local_authorities.csv'
LOAD_SQL = REPO_ROOT / 'load.sql'
UPDATE_SQL = REPO_ROOT / 'update.sql'

REMOTE_REPO_URL = 'https://github.com/LibrariesHacked/mobilelibraries-data.git'

# Known name mappings from older database names to standardized names in mobilelibraries-data
NAME_ALIASES = {
    'Durham': 'County Durham',
    'Scottish Borders': 'The Scottish Borders',
    'Anglesey': 'Isle of Anglesey',
    'North Yorkshire County': 'North Yorkshire',
    'Somerset County': 'Somerset',
}

# Inverted mapping to preserve database compatibility if needed
CANONICAL_TO_DB_NAME = {v: k for k, v in NAME_ALIASES.items()}


def get_source_data_dir(custom_source=None):
    """
    Finds the mobilelibraries-data repository directory.
    Checks:
    1. Custom path if supplied via --source
    2. Sibling directory ../mobilelibraries-data
    3. Shallow clone of remote repo into temporary directory
    """
    if custom_source:
        p = Path(custom_source).resolve()
        if p.exists() and (p / 'data').exists():
            return p, False
        raise FileNotFoundError(f"Source directory not found or missing 'data': {custom_source}")

    sibling = REPO_ROOT.parent / 'mobilelibraries-data'
    if sibling.exists() and (sibling / 'data').exists():
        print(f"Using local sibling repository at: {sibling}")
        return sibling, False

    print(f"Cloning latest data from {REMOTE_REPO_URL}...")
    temp_dir = tempfile.mkdtemp(prefix='mobilelibraries-data-')
    subprocess.run(
        ['git', 'clone', '--depth', '1', REMOTE_REPO_URL, temp_dir],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return Path(temp_dir), True


def sync_organisations(source_dir):
    """
    Ensures data/organisations.csv is synchronized with active services and latest GSS codes.
    """
    services_path = source_dir / 'services.csv'
    if not services_path.exists():
        print("Warning: services.csv not found in source; keeping existing organisations.csv")
        return

    existing_orgs = []
    if ORGS_CSV.exists():
        with open(ORGS_CSV, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            existing_orgs = list(reader)

    org_by_name = {r['authority']: r for r in existing_orgs}
    org_by_code = {r['code']: r for r in existing_orgs if r['code']}

    services_list = []
    with open(services_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        services_list = list(reader)

    updated_orgs = []
    seen_authorities = set()

    for org in existing_orgs:
        auth = org['authority']
        # Check alias
        lookup_name = NAME_ALIASES.get(auth, auth)

        # Find matching service by code or name (prioritising active services)
        matched_service = None
        for s in services_list:
            if (s['local_authority'] == lookup_name or s['local_authority_code'] == org.get('code')) and s.get('has_mobile_service') == 'Yes':
                matched_service = s
                break
        if not matched_service:
            for s in services_list:
                if s['local_authority'] == lookup_name or s['local_authority_code'] == org.get('code'):
                    matched_service = s
                    break

        if matched_service:
            # Update authority name to canonical version (e.g. County Durham, Somerset)
            org['authority'] = matched_service['local_authority']
            org['country'] = matched_service.get('nation') or org.get('country', '')
            org['code'] = matched_service['local_authority_code']
            if not org.get('website') and matched_service.get('source_url'):
                org['website'] = matched_service['source_url']

        if org['authority'] not in seen_authorities:
            updated_orgs.append(org)
            seen_authorities.add(org['authority'])

    # Add any active mobile library services missing from organisations.csv
    for s in services_list:
        if s.get('has_mobile_service') == 'Yes':
            auth_name = s['local_authority']
            if auth_name not in seen_authorities:
                new_entry = {
                    'authority': auth_name,
                    'country': s.get('nation', ''),
                    'code': s.get('local_authority_code', ''),
                    'website': s.get('source_url', ''),
                    'email': '',
                    'domain': '',
                    'colour': '#00728F',
                    'logo': ''
                }
                updated_orgs.append(new_entry)
                seen_authorities.add(auth_name)

    # Sort by authority name
    updated_orgs.sort(key=lambda x: x['authority'])

    for target_csv in (ORGS_CSV, LOCAL_AUTHORITIES_CSV):
        with open(target_csv, 'w', encoding='utf-8', newline='') as f:
            fieldnames = ['authority', 'country', 'code', 'website', 'email', 'domain', 'colour', 'logo']
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(updated_orgs)

    print(f"Updated {ORGS_CSV} and {LOCAL_AUTHORITIES_CSV} with {len(updated_orgs)} authorities.")


def sync_data_files(source_dir):
    """
    Copies stops and routes CSVs from source into database repo data directory.
    Returns list of tuples: (authority_name, dataset_slug, stops_count, trips_count)
    """
    DATA_DIR.mkdir(exist_ok=True)
    ROUTES_DIR.mkdir(exist_ok=True)

    src_data = source_dir / 'data'
    src_routes = src_data / 'routes'

    synced = []

    # Get all authority stop files (excluding unified/meta files)
    stop_files = sorted(
        [
            f for f in src_data.glob('*.csv')
            if not f.name.startswith('uk_')
            and not f.name.startswith('geocoding_')
            and not f.name.startswith('library-')
            and f.name != 'organisations_scotland.csv'
        ]
    )

    current_slugs = set()

    for sf in stop_files:
        slug = sf.stem
        current_slugs.add(slug)

        dest_sf = DATA_DIR / sf.name
        shutil.copy2(sf, dest_sf)

        rf_name = f"{slug}_routes.csv"
        src_rf = src_routes / rf_name
        dest_rf = ROUTES_DIR / rf_name

        trips_count = 0
        if src_rf.exists():
            shutil.copy2(src_rf, dest_rf)
            with open(dest_rf, 'r', encoding='utf-8') as f:
                trips_count = sum(1 for _ in csv.DictReader(f))
        else:
            print(f"Notice: No routes file found for {slug}")

        with open(dest_sf, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            first_row = next(reader, None)
            authority_name = (
                (first_row.get('local_authority') or first_row.get('Local authority'))
                if first_row else slug.replace('_', ' ').title()
            )
            stops_count = (1 if first_row else 0) + sum(1 for _ in reader)

        synced.append((authority_name, slug, stops_count, trips_count))

    # Clean up obsolete authority files in data/
    for existing_f in DATA_DIR.glob('*.csv'):
        if existing_f.name in ('organisations.csv', 'local_authorities.csv'):
            continue
        if existing_f.stem.endswith('_routes'):
            # Old route files in data root are superseded by data/routes/
            existing_f.unlink()
            continue
        if existing_f.stem not in current_slugs:
            print(f"Removing obsolete dataset: {existing_f.name}")
            existing_f.unlink()

    for existing_rf in ROUTES_DIR.glob('*_routes.csv'):
        base_slug = existing_rf.name[:-11]
        if base_slug not in current_slugs:
            print(f"Removing obsolete route file: {existing_rf.name}")
            existing_rf.unlink()

    return synced


def generate_load_sql(synced_datasets):
    """
    Generates load.sql dynamically for all synced authorities in alphabetical order.
    """
    lines = []
    lines.append("-- create temp table for local authorities")
    lines.append("create table local_authority_temp (")
    lines.append("\tname character varying (200) not null,")
    lines.append("\tcountry character varying (200) not null,")
    lines.append("\tcode character (9),")
    lines.append("\twebsite character varying (200),")
    lines.append("\temail character varying (200),")
    lines.append("\tdomain character varying (200),")
    lines.append("\tcolour character (7),")
    lines.append("\tlogo character varying (200)")
    lines.append(");")
    lines.append("")
    lines.append("-- import local authorities")
    lines.append("\\copy local_authority_temp from 'data/local_authorities.csv' csv header;")
    lines.append("")
    lines.append("-- import countries")
    lines.append("insert into country(name)")
    lines.append("select distinct country from local_authority_temp order by country;")
    lines.append("")
    lines.append("-- insert into local_authority table")
    lines.append("insert into local_authority(name, country_id, code, website, email, colour, logo)")
    lines.append("select t.name, c.id, t.code, t.website, t.email, t.colour, t.logo from local_authority_temp t join country c on c.name = t.country order by c.id, t.name;")
    lines.append("")
    lines.append("drop table local_authority_temp;")
    lines.append("")

    # Sort datasets alphabetically by authority name
    sorted_datasets = sorted(synced_datasets, key=lambda x: x[0])

    for authority_name, slug, stops_count, trips_count in sorted_datasets:
        escaped_name = authority_name.replace("'", "''")
        lines.append(f"-- load {authority_name}")
        lines.append(f"\\copy stop_staging from 'data/{slug}.csv' csv header;")
        lines.append(f"select fn_load_stops_staging(local_authority_name := '{escaped_name}');")
        route_file = f"data/routes/{slug}_routes.csv"
        if (ROUTES_DIR / f"{slug}_routes.csv").exists():
            lines.append(f"\\copy trip_staging from '{route_file}' csv header;")
            lines.append(f"select fn_load_trips_staging(local_authority_name := '{escaped_name}');")
        lines.append("")

    lines.append("-- update schedule and location estimates")
    lines.append("select fn_updates();")
    lines.append("")
    lines.append("vacuum analyze;")
    lines.append("")

    with open(LOAD_SQL, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

    print(f"Generated {LOAD_SQL} for {len(sorted_datasets)} authorities.")


def generate_update_sql():
    """
    Generates update.sql for atomic, transactional updates of an existing live database.
    """
    content = """-- =============================================================================
-- Atomic transactional refresh of mobile libraries database
-- =============================================================================
\\set ON_ERROR_STOP on
set client_encoding = 'UTF8';

begin;

-- Truncate existing data tables (cascade handles dependent route_stop, mobile_location, route_schedule, trip)
truncate table route_stop, trip, route_schedule, mobile_location, route, stop, mobile, local_authority, country, updates restart identity cascade;

-- Load latest data from load.sql
\\i 'load.sql';

commit;
"""
    with open(UPDATE_SQL, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"Generated {UPDATE_SQL}.")


def main():
    parser = argparse.ArgumentParser(description="Sync data from mobilelibraries-data into mobilelibraries-database")
    parser.add_argument('--source', '-s', help="Path to local mobilelibraries-data repository", default=None)
    args = parser.parse_args()

    source_dir, is_temp = get_source_data_dir(args.source)
    try:
        print(f"Syncing from source: {source_dir}")
        sync_organisations(source_dir)
        synced = sync_data_files(source_dir)
        generate_load_sql(synced)
        generate_update_sql()

        total_stops = sum(s[2] for s in synced)
        total_trips = sum(s[3] for s in synced)
        print("=" * 60)
        print(f"SYNC COMPLETE: {len(synced)} authorities synced.")
        print(f"Total stops: {total_stops:,} | Total trips: {total_trips:,}")
        print("=" * 60)
    finally:
        if is_temp:
            print(f"Cleaning up temporary clone directory {source_dir}...")
            shutil.rmtree(source_dir, ignore_errors=True)


if __name__ == '__main__':
    main()
