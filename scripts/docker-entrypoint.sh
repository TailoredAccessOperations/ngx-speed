#!/bin/bash

set -e

/usr/local/bin/initialize.sh || exit 1

echo "starting nginx web server..."

if [[ "$1" == -* ]]; then
    set -- nginx "$@"
fi

exec "$@"