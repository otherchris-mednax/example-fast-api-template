#!/usr/bin/env bash
###############################################
#   THIS SCRIPT NEEDS TO BE MODIFIED FOR YOUR PROJECT NEEDS   #
###############################################

cd "${0%/*}" || exit
BUILD_SCRIPTS_DIR="$(dirname "$(pwd)")"
PROJECT_DIR="$(dirname "$BUILD_SCRIPTS_DIR")"

# Enable if you need a secret
# source .env

ENV=$1

if [[ $ENV == "dev" ]]; then
  BASE_URL="https://fast-api-template.mdnxdev.com"
elif [[ $ENV == "test" ]]; then
  BASE_URL="https://fast-api-template.mdnxtest.com"
elif [[ $ENV == "stage" ]]; then
  BASE_URL="https://fast-api-template.mdnxstage.com"
fi

HEALTH_URL_PATH="${BASE_URL}/health"
HELLO_URL_PATH="${BASE_URL}/hello"

echo "==> Testing ${ENV} environment..."

cd "$PROJECT_DIR" || exit

echo "==> Getting token..."
AUD=""

TOKEN=$(curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&scope=$AUD/.default&grant_type=client_credentials" "https://login.microsoftonline.com/ae2bff4d-4382-4532-b4a0-f1e5a9c874a8/oauth2/v2.0/token" 2>/dev/null | jq -r .access_token)

echo
echo "==> GET request to the following URL: ${HEALTH_URL_PATH}..."
curl -X "GET" -i \
  "${HEALTH_URL_PATH}"

echo
echo "==> GET request to the following URL: ${HELLO_URL_PATH}..."
curl -X "GET" -i \
  "${HELLO_URL_PATH}"

echo
echo "==> POST request to the following URL: ${HELLO_URL_PATH}..."
curl -X "POST" -i \
  "${HELLO_URL_PATH}" \
  -H "accept: application/json" -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
