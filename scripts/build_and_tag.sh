#!/bin/bash
set -e

# Define variables
PROJECT_NAME="nginx-pagespeed"
IMAGE_NAME="${PROJECT_NAME}"
GIT_COMMIT=$(git rev-parse --short HEAD)
BUILD_DATE=$(date +%Y%m%d-%H%M%S)

# Check if a tag was provided
if [[ "$1" != "" ]]; then
   TAG_NAME="$1"
else
  TAG_NAME="${BUILD_DATE}-${GIT_COMMIT}"
fi

# Build the docker image with tag
docker build -t "${IMAGE_NAME}:${TAG_NAME}" .

echo "Docker image built and Tagged as ${IMAGE_NAME}:${TAG_NAME}"

