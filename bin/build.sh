#!/usr/bin/env bash

# bin/build.sh: Build the project into a distributable form, including both any
#               compiling and/or packaging, e.g., Docker images.

set -e

# Set the working directory to be the project's base directory; all
# subsequent paths are relative to that base directory.
cd "$(dirname "$0")/.."

source bin/build_variables.sh


echo "🤖 ⟶  Authenticate with Mednax Container Registry…"
az acr login --name mednax

echo "🤖 ⟶  Building Docker image…"
eval "docker build \
        --pull \
        --build-arg VERSION=${VERSION} \
        --build-arg PROJECT_NAME=${PROJECT_NAME} \
        --build-arg JFROG_USER=${JFROG_USER} \
        --secret id=ARTIFACT_ACCESS_TOKEN \
        -t $IMAGE_NAME ."
