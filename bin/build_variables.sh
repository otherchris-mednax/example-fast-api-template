#!/usr/bin/env bash

# bin/build_variables.sh: Sets any required env vars.

set -e

PROJECT_NAME=$(poetry version | awk '{print $1}')
export PROJECT_NAME
export IMAGE_NAME="mednax/$PROJECT_NAME"

VERSION="$(poetry version --short)"
export VERSION

OS="$(uname -s)"
if [ "${OS}" = "Linux" ]; then
    export GREEN='\e[32m'
    export BLUE='\e[34m'
    export PURPLE="\e[35m"
    export YELLOW='\e[0;33m'
    export RED='\e[31m'
    export RESET='\e[0m'
elif [ "${OS}" = "Darwin" ]; then
    export GREEN='\033[32m'
    export BLUE='\033[34m'
    export PURPLE="\033[35m"
    export YELLOW='\033[33m'
    export RED='\033[31m'
    export RESET='\033[m'
fi
