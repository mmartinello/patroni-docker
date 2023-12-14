#!/bin/bash

# Run Patroni
echo "Executing Patroni ..."

# Environment deafult
PATRONI_CONF_FILE_PATH=${PATRONI_CONF_FILE_PATH:-/etc/patroni.yml}

# Load the virtualenv
export VIRTUAL_ENV=/app
export PATH="$VIRTUAL_ENV/bin:$PATH"

# Execute Patroni
patroni $PATRONI_CONF_FILE_PATH
