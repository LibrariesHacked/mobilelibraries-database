# Mobile Libaries Database

This is the database for the [mobile libraries project](https://blog.librarydata.uk/mobile-library-data-project). The database is developed using PostgreSQL and PostGIS.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See the deployment for notes on how to deploy the project on a live system.

### Prerequisites

To get this database up and running you'll need a PostgreSQL Server, version 10. With a compatible PostGIS installed.

- [PostgreSQL](https://www.postgresql.org/)
- [PostGIS](https://postgis.net/)

### Installing

To manually install the database schema, follow through the SQL scripts documented in the [create.sql](create.sql) file. This could be done directly on the local database using a tool such as [PGAdmin 4](https://www.pgadmin.org/download/). Alternatively, move on to the deployment section to deploy directly to a server.

## Deployment

On a live system it is more likely you will need to remotely run the [create.sql](create.sql) script, which is set up to be able to be run remotely using psql. In a Windows environment a sample of doing this is included in the [create.bat](create.bat) file.

## Authors

- **Dave Rowe** - *Initial work* - [DaveBathnes](https://github.com/DaveBathnes)

See also the list of [contributors](https://github.com/librarieshacked/mobilelibraries-database/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

- All mobile library services
