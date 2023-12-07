# PostgreSQL major version
ARG PG_MAJOR=14

# Starting from PostgreSQL image
FROM postgres:$PG_MAJOR

# Metadata
LABEL version="1.0"
LABEL description="Patroni Docker Image"
LABEL maintainer="Mattia Martinello <mattia@mattiamartinello.com>"

# Install build dependencies
#RUN set -ex \
#    && BUILD_DEPS=" \
#    build-essential \
#    libpq-dev \
#    "
#RUN apt-get update && apt-get install -y --no-install-recommends $BUILD_DEPS \
#    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python stuffs
RUN apt-get update -y && apt-get install -y \
    python3-pip \
    python3.11-venv \
    && rm -rf /var/lib/apt/lists/*

# Clean
RUN apt-get clean

# Create a virtualenv
ENV VIRTUAL_ENV=/app
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Patroni
RUN pip install patroni[psycopg2,etcd]

# Remove build dependencies
RUN apt-get remove --purge -y $BUILD_DEPS
