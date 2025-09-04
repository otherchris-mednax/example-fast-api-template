#!/usr/bin/env bash

# bin/acceptance_tests.sh: Run any and all acceptance/integration/end-to-end
#                          tests, particularly those that may require more
#                          setup/time to run.

set -e

# Set the working directory to be the project's base directory; all
# subsequent paths are relative to that base directory.
cd "$(dirname "$0")/.."

source bin/build_variables.sh

ACCEPTANCE_TEST_DIR="tests/acceptance"

dc()
{
  docker compose --file ./docker-compose.yml --file ./docker-compose.acceptance-tests.yml "$@"
}

cleanup()
{
  exit_code=$?
  echo "🤖 ⟶  Archiving logs…"
  docker cp test:/app/tests/reports tests
  dc logs app >> $ACCEPTANCE_TEST_DIR/logs/app.log
  dc logs test >> $ACCEPTANCE_TEST_DIR/logs/test.log
  echo "🤖 ⟶  Shutting down Docker environment…"
  dc down --timeout 0
  echo "🤖 ⟶  Exiting acceptance tests with code ${exit_code}."
  exit $exit_code
}

echo "🤖 ⟶  Creating log dir…"
mkdir -p $ACCEPTANCE_TEST_DIR/logs
rm -f $ACCEPTANCE_TEST_DIR/logs/*

echo "🤖 ⟶  Creating reports dir…"
mkdir -p tests/reports
rm -rf tests/reports/TESTS-*.xml

echo "🤖 ⟶  Spinning up Docker environment…"
dc down
dc pull mock_oauth2_server test
dc up --detach

echo "🤖 ⟶  Preparing Docker environment…"
docker cp ./tests test:/app
dc exec test bash -c \
    "mkdir -pv ./tests/reports \
    && mkdir -pv ./tests/acceptance/error \
    && touch ./tests/acceptance/error/error.log"

echo "🤖 ⟶  Executing acceptance tests…"
trap cleanup EXIT
if [ -z "$TAGS" ]; then
  TAGS="~@wip"
fi

dc exec test bash -c \
    "cd tests/acceptance && \
    poetry run behave --tags=${TAGS} --junit --junit-directory ../reports"
