# This Dockerfile build a Docker image with PostgreSQL and pg_cron,
# PostGIS, pgRouting and Patroni

# PostgreSQL major version
ARG PG_MAJOR=14

# Starting from PostgreSQL image
FROM postgres:$PG_MAJOR as builder

# Create a new image
FROM scratch
COPY --from=builder / /

# Metadata
LABEL version="1.0"
LABEL description="Patroni Docker Image"
LABEL maintainer="Mattia Martinello <mattia@mattiamartinello.com>"

# PostgreSQL major version
ARG PG_MAJOR=14

# Install pg_cron
ARG INSTALL_PG_CRON=true

# Install PostGIS
ARG INSTALL_POSTGIS=true

# Install pgRouting
ARG INSTALL_PGROUTING=true

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
RUN pip install patroni[psycopg2,etcd]
COPY run.sh /

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
