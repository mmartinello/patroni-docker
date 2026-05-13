#!/bin/bash

# Run sshd (needed for pgBackRest)
SSH_RUN=${SSH_RUN:-false}

if [ "$SSH_RUN" == "true" ]; then
    echo "Executing sshd ..."
    
    mkdir -p /var/lib/postgresql/.ssh
    chmod 700 /var/lib/postgresql/.ssh
    touch /var/lib/postgresql/.ssh/known_hosts
    chmod 644 /var/lib/postgresql/.ssh/known_hosts
    
    sudo /usr/sbin/sshd &
fi

# Run Patroni
echo "Executing Patroni ..."

# Environment deafult
PATRONI_CONF_FILE_PATH=${PATRONI_CONF_FILE_PATH:-/etc/patroni.yml}

# Load the virtualenv
export VIRTUAL_ENV=/app
export PATH="$VIRTUAL_ENV/bin:$PATH"

# Execute Patroni
patroni $PATRONI_CONF_FILE_PATH
