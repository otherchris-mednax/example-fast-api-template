#!/usr/bin/env bash

# bin/analyze_image.sh: Run post-build analysis on the project.

set -e

# Set the working directory to be the project's base directory; all
# subsequent paths are relative to that base directory.
cd "$(dirname "$0")/.."

source bin/build_variables.sh

echo "🤖 ⟶  Running Trivy analysis"
trivy image \
  --ignore-unfixed \
  --exit-code 1 \
  --severity HIGH,CRITICAL \
  "$IMAGE_NAME"
