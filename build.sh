#!/bin/bash

# Builds docker image with neovim on top of project's dev image.
#
# Usage: docker-build.sh <project-dir>
#
# E.g.:  docker-build.sh ~/Projects/rust-sandbox
#
# This script will create two images:
# - "<project-name>-base": base image build from project's .devcontainer/Dockerfile
# - "<project-name>": base image + neovim and other common utils

# exit on first error
set -e

PROJECT_DIR="$1"
PROJECT_NAME=$(basename "$PROJECT_DIR")
PROJECT_DOCKERFILE=$PROJECT_DIR/.devcontainer/Dockerfile

NEOVIM_DOCKERFILE=$(dirname $(realpath "$0"))/Dockerfile

PROJECT_IMAGE_NAME=$PROJECT_NAME-base
NEOVIM_IMAGE_NAME=$PROJECT_NAME

# Build base image
docker build \
    -t $PROJECT_IMAGE_NAME \
    -f $PROJECT_DOCKERFILE \
    $PROJECT_DIR

# Build target image
docker build \
    --build-arg BASE_IMAGE=$PROJECT_IMAGE_NAME \
    -t $NEOVIM_IMAGE_NAME \
    -f $NEOVIM_DOCKERFILE \
    .
