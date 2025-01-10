#!/bin/bash
set -e

# variables
COMPOSE_FILE="docker-compose.yml"

# Ask user for tag when prompt for build image. If no tag is specified, then the default tag will be used.
read -r -p "Enter the docker image tag for this build (or press Enter for default tag): " image_tag_name

# Build and tag docker image with the tag provided by user, or using a default tag if empty string provided.
./scripts/build_and_tag.sh "$image_tag_name"

if [ ! -f .env ]; then #Check if the .env file exits.
   echo ".env file does not exists, creating one with default values from .env-example."
   cp .env-example .env #copy .env-example to .env for the first time.
fi

docker-compose up --build -d --remove-orphans # docker compose command.

echo "Project setup complete." # Final message.

