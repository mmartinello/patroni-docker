# This Dockerfile build a Docker image with PostgreSQL and pg_cron,
# PostGIS, pgRouting and Patroni

# PostgreSQL major version
ARG PG_MAJOR=16

# Starting from PostgreSQL image
FROM postgres:$PG_MAJOR as builder

# Create a new image
FROM scratch
COPY --from=builder / /

# PostgreSQL major version
ARG PG_MAJOR=16

# Patroni version
ARG PATRONI_VERSION=3.3.0

# PostgreSQL additional version (will additionally installed beyond the major
# version specified before only if this variable is specified)
ARG ADDITIONAL_PG_MAJORS=""

# Additional locales to be installed (separated by space)
ARG ADDITIONAL_LOCALES=""

# Install pg_cron
ARG INSTALL_PG_CRON=false

# Install PostGIS
ARG INSTALL_POSTGIS=false

# Install pgRouting
ARG INSTALL_PGROUTING=false

# Metadata
LABEL version="1.0"
LABEL description="Patroni Docker Image"
LABEL maintainer="Mattia Martinello <mattia@mattiamartinello.com>"

# Install build stuffs
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python stuffs
RUN apt-get update -y && apt-get install -y \
    python3-pip \
    python3.11-venv \
    && rm -rf /var/lib/apt/lists/*

# Install additional locales if ADDITIONAL_LOCALES is set
RUN if [ -n "$ADDITIONAL_LOCALES" ]; then \
        locales=$(echo $ADDITIONAL_LOCALES); \
        for locale in $locales; do \
            echo "Installing locale: $locale"; \
            sed -i "/^#\s*${locale}/s/^#\s*//" /etc/locale.gen; \
        done && locale-gen; \
    else \
        echo "No additional locales to install."; \
    fi

# Create a virtualenv
ENV VIRTUAL_ENV=/app
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install pg_cron if enabled
RUN if [ "$INSTALL_PG_CRON" = "true" ]; then \
        apt-get update -y && apt-get install -y \
        postgresql-$PG_MAJOR-cron \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# Install PostGIS if enabled
RUN if [ "$INSTALL_POSTGIS" = "true" ]; then \
        apt-get update -y && apt-get install -y \
        postgresql-$PG_MAJOR-postgis-3 \
        postgresql-$PG_MAJOR-postgis-3-scripts \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# Install pgRouting if enabled
RUN if [ "$INSTALL_PGROUTING" = "true" ]; then \
        apt-get update -y && apt-get install -y \
        postgresql-$PG_MAJOR-pgrouting \
        postgresql-$PG_MAJOR-pgrouting-scripts \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# Install Patroni
RUN pip install patroni[psycopg2,etcd]==$PATRONI_VERSION
COPY run.sh /

# Install additionals PostgreSQL versions
# looping through ADDITIONAL_PG_MAJORS array
RUN for ADDITIONAL_PG_MAJOR in $ADDITIONAL_PG_MAJORS; do \
    apt-get update -y && apt-get install -y \
    postgresql-$ADDITIONAL_PG_MAJOR \
    && rm -rf /var/lib/apt/lists/*; \
    done;

# Remove build dependencies
RUN apt-get remove --purge -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Clean
RUN apt-get clean

# Run Patroni
USER postgres
WORKDIR /
CMD /run.sh
