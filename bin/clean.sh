#!/usr/bin/env bash

# bin/clean.sh: Clean up the project, including any temporary files.

set -e

# Set the working directory to be the project's base directory; all
# subsequent paths are relative to that base directory.
cd "$(dirname "$0")/.."

source bin/build_variables.sh

if [[  -d "venv" ]];then
    echo "🤖 ⟶  Removing venv subdirectory…"
    rm -rf venv
fi

if [[  -d ".venv" ]];then
    echo "🤖 ⟶  Removing .venv subdirectory…"
    rm -rf .venv
fi

if [[ $(poetry env list) ]];then
    echo "🤖 ⟶  Removing Poetry env…"
    poetry env remove "$(poetry env info --path)/bin/python"
fi

if [[  -d ".pytest_cache" ]];then
    echo "🤖 ⟶  Removing .pytest_cache subdirectory…"
    rm -rf .pytest_cache
fi

echo "🤖 ⟶  Removing __pycache__ subdirectories…"
find . -type d -name "__pycache__" -exec rm -r "{}" \; -prune

TO_KILL=$(docker ps -q -a -f status=running)
if [[ -n $TO_KILL ]]; then
    echo "🤖 ⟶  Kill any running instances"
    docker kill "$TO_KILL"
fi

TO_REMOVE=$(docker ps -q -f status=exited)
if [[ -n $TO_REMOVE ]]; then
    echo "🤖 ⟶  Remove any exited instances"
    docker rm "$TO_REMOVE"
fi

IMAGE_EXISTS=$(docker images -q ${IMAGE_NAME}:latest)
if [[ -n $IMAGE_EXISTS ]]; then
    echo "🤖 ⟶  Removing image ${IMAGE_NAME}"
    docker rmi ${IMAGE_NAME}:latest
fi

DANGLING_IMAGES_TO_REMOVE=$(docker images -f "dangling=true" -q | tr "\n" " ")
if [[ -n $DANGLING_IMAGES_TO_REMOVE ]]; then
    echo "🤖 ⟶  Remove dangling images: ${DANGLING_IMAGES_TO_REMOVE}"
    docker image prune -f
fi
