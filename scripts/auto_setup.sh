#!/bin/bash

# Navigate to the project root
cd /com.docker.devenvironments.code/docker-nginx

# Initialize a new Git repository
git init

# Add all files to the staging area
git add .

# Commit the initial state with a meaningful message
git commit -m "Initial commit: Project Reorganization"

# Create the .dockerignore file
touch .dockerignore

# Write the following content to .dockerignore
echo '.git
**/__pycache__
**/*.pyc
**/*.pyo
*.log
*.swp
*~
.DS_Store
.env' >> .dockerignore

# Stage and commit
git add .dockerignore
git commit -m "add .dockerignore file"

# Write the following content to .env-example
echo '# Environment variables example

# Nginx Configurations
NGINX_VERSION=1.25.3
# Pagespeed Configurations
PAGESPEED_VERSION=1.13.35.2
# libpng configuration
LIBPNG_VERSION=1.6.40
# Number of jobs for the build phase.
MAKE_J=4' > .env-example

# Stage and commit
git add .env-example
git commit -m "add .env-example with usage description"

git add cloudbuild.yaml
git commit -m "add cloudbuild for google cloud build"


git add mime.types
git commit -m "add mime type file"

# Replace the content of the README.md for project description
echo '# Nginx with Pagespeed docker image

This project provides an optimized Nginx Docker image with the PageSpeed module and other useful extensions.

## Features

-   Optimized Nginx for high performance.
-   PageSpeed enabled for automatic web page optimization.
-   Multi-stage docker builds for minimal image size
-   Modular Nginx configuration.
-   Properly documented.
-   Easy to set up and run with docker compose.
-   Automatic TLS certificate generation with self-signed configuration.
-   Proper environment variable support.
 
## Usage

1.  Clone the repository.
2.  Customize environment variables in `.env` file using `.env-example` as a template.
3.  Build and run the docker container using:
   ```bash
   docker-compose up --build -d
   ```
4.  Access the web server at `http://localhost` or `https://localhost`.

## Advanced Customisation
1. Modify the configurations in `config` folder and rebuild the docker images using `docker-compose up --build -d`
2.  Modify the `scripts` for custom docker entrypoint and startup functionalities.

## Important Notice
  * Self-signed certificates are generated when the container starts for the first time.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
' > README.md
git add README.md
git commit -m "updated README.md file with proper information."

git add docker-compose.yml
git commit -m "updated docker-compose.yaml file for resource usage"

git add config
git commit -m "added all config files for project"

git add scripts
git commit -m "added required entry point and initial scripts files."

# Create scripts/build_and_tag.sh file
echo '#!/bin/bash
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
' > scripts/build_and_tag.sh

# Make build_and_tag.sh executable
chmod +x scripts/build_and_tag.sh

git add scripts/build_and_tag.sh
git commit -m "added build and tag script"


# Create scripts/auto_setup.sh script
echo '#!/bin/bash
set -e

# Variables
COMPOSE_FILE="docker-compose.yml"

# Ask user for tag when prompt for build image. If no tag is specified, then the default tag will be used.
read -r -p "Enter the docker image tag for this build (or press Enter for default tag): " image_tag_name

# Build and tag docker image with the tag provided by user, or using a default tag if empty string provided.
./scripts/build_and_tag.sh "$image_tag_name"

if [ ! -f .env ]; then # Check if the .env file exits.
   echo ".env file does not exist, creating one with default values from .env-example."
   cp .env-example .env # Copy .env-example to .env for the first time.
fi

docker-compose up --build -d --remove-orphans # Docker compose command.

echo "Project setup complete." # Final message.
' > scripts/auto_setup.sh

# Make auto_setup.sh executable
chmod +x scripts/auto_setup.sh


git add scripts/auto_setup.sh
git commit -m "added auto setup script to the project"

# Final commit
git add .
git commit -m "Final project setup with all required scripts"

# Create and switch to a 'develop' branch
git checkout -b develop

echo "Project setup complete. You are now on the 'develop' branch."
