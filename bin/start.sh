#!/usr/bin/env bash

# bin/start.sh: Launch the project and any extra required processes locally.

set -e

# Set the working directory to be the project's base directory; all
# subsequent paths are relative to that base directory.
cd "$(dirname "$0")/.."

source bin/build_variables.sh

dc()
{
  docker-compose --file ./docker-compose.yml "$@"
}

cleanup()
{
  echo "🤖 ⟶  Shutting down Docker environment…"
  dc down --timeout 0
}

echo "🤖 ⟶  Starting the project…"
dc down
dc up --detach

trap cleanup EXIT
while true; do
    echo '🤖 ⟶  Press Ctrl+C to shutdown containers'
    sleep 100
done
