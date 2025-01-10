#!/bin/bash
set -e

# variables
COMPOSE_FILE="docker-compose.yml"
PROJECT_ROOT=$(dirname "$0")/..

# Ask user for tag when prompt for build image. If no tag is specified, then the default tag will be used.
set +x   # Disable debug for read prompt
IFS= read -n 1 -p "Enter the docker image tag for this build (or press Enter for default tag): " image_tag_name_input
set -x  # Enable back for other commnads

# use the user defined input, or use empty string as default if input is empty, this way no extra enter press needed.
if [[ -z "$image_tag_name_input" ]]; then
    image_tag_name=""
else
  image_tag_name="$image_tag_name_input"
fi

# Build and tag docker image with the tag provided by user, or using a default tag if empty string provided.
"$PROJECT_ROOT"/scripts/build_and_tag.sh "$image_tag_name"

if [ ! -f "$PROJECT_ROOT"/.env ]; then #Check if the .env file exits.
   echo ".env file does not exists, creating one with default values from .env-example."
   cp "$PROJECT_ROOT"/.env-example "$PROJECT_ROOT"/.env #copy .env-example to .env for the first time.
fi

docker-compose -f "$PROJECT_ROOT/$COMPOSE_FILE" up --build -d --remove-orphans # docker compose command.

echo "Project setup complete." # Final message.