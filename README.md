PostgreSQL, pgBackRest and Patroni Docker image with additional extensions and
multiple additional PostgreSQL versions
===============================================================================

## Description

This Docker project builds a Docker image to run a PostgreSQL cluster using
Patroni.

Some additional extensions and multiple additional PostgreSQL versions can be
installed if needed.

## Features

The following packages are installed in the image per default:

* [PostgreSQL](https://www.postgresql.org/) is a free and open-source relational
database management system (RDBMS) emphasizing extensibility and SQL compliance.

* [Patroni](https://github.com/zalando/patroni) is a template for high
availability (HA) PostgreSQL solutions using Python. Patroni needs one of the
following distributed configuration store systems: ZooKeeper, etcd, Consul or
Kubernetes. In this image Patroni is installed with dependencies for **etcd**.

* [pgBackRest](https://pgbackrest.org/) is a reliable backup and restore
solution for PostgreSQL that seamlessly scales up to the largest databases and
workloads.

#### Additional extensions:

The following extensions can be installed if needed by setting their
corresponding environment variables to `true` in the build command (see [Build
arguments](#build-arguments-environment-variables)):

* [pg_cron](https://github.com/citusdata/pg_cron) is a simple cron-based job
scheduler for PostgreSQL.

* [PostGIS](https://postgis.net/) extends the capabilities of the PostgreSQL
relational database by adding support storing, indexing and querying geographic
data.

* [pgRouting](https://pgrouting.org/) extends the PostGIS / PostgreSQL
geospatial database to provide geospatial routing functionality.

* [pgvector](https://github.com/pgvector/pgvector) is an extension to add
support for vector similarity search to PostgreSQL.

#### Additional PostgreSQL versions:

This Docker image also allows to install additional PostgreSQL major versions
(useful in case of upgrades) and additional locales (useful if you need
specific collations for databases).

## Tags

Tags use the following schema: `<patroni_version>-pg<pg_major_version>-<image_variant>`.

Image variants contains the list of additoinal PostgreSQL extensions installed
in the image, in snake_case, for example:

* `pgcron`: pg_cron
* `pgcron-postgis`: pg_cron and PostGIS
* `pgcron-pgrouting`: pg_cron and pgRouting
* ...

If image variant is not specified, no additional extensions are installed.

The `latest` tag does not contain any additional extensions.

All images are based on Debian 12 Bookworm.

## Volumes

The following volumes should be configured or mounted for data to be
persistent:

* `/var/log/patroni`: the log directory where Patroni writes log files in
* `/var/lib/postgresql`: the PostgreSQL data directory where PostgreSQL write
data into
* `/etc/patroni.yml`: the Patroni local configuration file

## Ports

This Docker image listens on the following ports:

* PostgreSQL port: default `5432`
* Patroni REST API port: default `8008`

## Configuration

Patroni can be configured in several ways: global dynamic configuration,
local configuration file or environent variables. You can use the configuration
type you prefer, or a group of them. Please refer to [Patroni documentation](https://patroni.readthedocs.io/en/latest/patroni_configuration.html) for
more information.

## Build instructions

### Build arguments (environment variables)

##### PostgreSQL major version:

`PG_MAJOR`: set the PostgreSQL major version to be used (default `17`).

##### Additional extensions:

`INSTALL_PG_CRON`: **pg_cron** will be installed if this variable is set to
`true`, you can set it to `false` or any other value if you don't want
**pg_cron** to be installed. The default value is `false`.

`INSTALL_POSTGIS`: **PostGis** will be installed if this variable is set to
`true`, you can set it to `false` or any other value if you don't want
**PostGis** to be installed. The default value is `false`.

`INSTALL_PGROUTING`: **pgRouting** will be installed if this variable is set to
`true`, you can set it to `false` or any other value if you don't want
**pgRouting** to be installed. The default value is `false`.

`INSTALL_PGVECTOR`: **pgvector** will be installed if this variable is set to
`true`, you can set it to `false` or any other value if you don't want
**pgvector** to be installed. The default value is `false`.


##### Optional features:

`ADDITIONAL_PG_MAJORS`: to install multiple PostgreSQL major versions in the
image, declare here which major versions have to be installed other than the
main major version declared in `PG_MAJOR`. Multiple major versions should be
separated by spaces.

`ADDITIONAL_LOCALES`: to install multiple additional locales, declare here
which locales you need to be installed other than the default ones.
Multiple locales have to be separated by spaces.

### Installing additional PostgreSQL versions

To install multiple additional versions of PostgreSQL in the image, you can set
the `ADDITIONAL_PG_MAJORS` environment variable with an array containing the
additional major PostgreSQL versions you want to install.

This is particularly useful when you need to perform an upgrade of PostgreSQL
between major versions using the pg_upgrade command, which requires the
binaries of the previous PostgreSQL version you are upgrading from.

For example, to build a Docker image with additional PostgreSQL versions
16 and 15, you can use the following docker build command:

```
docker build --build-arg --build-arg ADDITIONAL_PG_MAJORS="16 15" -t my-postgres-patroni-image .
```

### Build the image

You can build the Docker image using the `docker build` command:

```
docker build -t <image_tag> .
```

If you wish to specify some build arguments you can add them with the
`--build-arg` parameter, for example:

```
docker build --build-arg='INSTALL_PG_CRON=false' -t <image_tag> .
```

### Installing additional PostgreSQL versions

To install multiple additional versions of PostgreSQL in the image, you can set
the `ADDITIONAL_PG_MAJORS` environment variable with an array containing the
additional major PostgreSQL versions you want to install.

This is particularly useful when you need to perform an upgrade of PostgreSQL
between major versions using the pg_upgrade command, which requires the
binaries of the previous PostgreSQL version you are upgrading from.

For example, to build a Docker image with additional PostgreSQL versions
12 and 13, you can use the following docker build command:

```
docker build --build-arg --build-arg ADDITIONAL_PG_MAJORS="12 13" -t my-postgres-patroni-image .
```

## Volumes

The following volumes should be configured or mounted for data to be
persistent:

* `/var/log/patroni`: the log directory where Patroni writes log files in
* `/var/lib/postgresql`: the PostgreSQL data directory where PostgreSQL write
data into
* `/etc/patroni.yml`: the Patroni local configuration file

## Ports

This Docker image listens on the following ports:

* PostgreSQL port: default `5432`
* Patroni REST API port: default `8008`

## Configuration

Patroni can be configured in several ways: global dynamic configuration,
local configuration file or environent variables. You can use the configuration
type you prefer, or a group of them. Please refer to [Patroni documentation](https://patroni.readthedocs.io/en/latest/patroni_configuration.html) for
more information.

## Maintainer

Mattia Martinello
