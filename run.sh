#!/bin/bash

# Runs docker container with neovim.
#
# Usage: docker-run.sh <project-name>
#
# E.g.:  docker-run.sh rust-sandbox
#
# This script will run neovim in docker container, and also mount project
# directory and some other stuff from host filesystem into container.

# exit on first error
set -e

PROJECT_DIR=$(realpath $1)
PROJECT_NAME=$(basename "$PROJECT_DIR")
NEOVIM_CONTAINER_NAME=$PROJECT_NAME
CONTAINER_WORK_DIR=/opt/workspace
SCRIPT_DIR=$(dirname "$(realpath "$0")")
# use absolute dir paths because docker doesn't work with relative ones
HOME_DIR=$(cd ~ && pwd)

# create a pipe, through which containers can open staff in host OS (e.g. browser links)
"$SCRIPT_DIR/browser_pipe.sh"

# define the command as a strings array, to be able to add per-line comments
CMD=(
  docker run
    --security-opt seccomp=unconfined # for valgrind to work inside container - disables ASLR for profiling

    --mount type=bind,source=$PROJECT_DIR,target=$CONTAINER_WORK_DIR
    --mount type=bind,source=$HOME_DIR/.config/nvim,target=/root/.config/nvim
    --mount type=bind,source=$HOME_DIR/.gitconfig,target=/root/.gitconfig # github config (user/email/etc.)
    --mount type=bind,source=/tmp/browser_pipe,target=/tmp/browser_pipe # see browser_pipe.sh

    # named volumes persist files in target directories independently of the container,
    # so they survive container removal and recreation, which happens on every "docker run"

    # share these volumes between all containers
    --mount type=volume,source=nvim-data,target=/root/.local/share/nvim # nvim plugins

    # keep these volumes project-specific where the state may depend on the environment.
    # otherwise, e.g. sharing the same rustup volume between containers would mean that
    # changing the rust toolchain in one container affects all other containers
    --mount type=volume,source=uv-data-$PROJECT_NAME,target=/root/.local/share/uv # python binaries
    --mount type=volume,source=cargo-data-$PROJECT_NAME,target=/usr/local/cargo # rust cargo cache
    --mount type=volume,source=rustup-data-$PROJECT_NAME,target=/usr/local/rustup # rust rustup toolchain

    --publish 8080
    --workdir $CONTAINER_WORK_DIR

    # remove the container on exit so repeated "docker run" commands don't leave
    # stopped containers behind in host file system
    --rm

    -it

    # allow catching TCP dump with tshark
    --cap-add=NET_RAW
    --cap-add=NET_ADMIN

    $NEOVIM_CONTAINER_NAME

    nvim .
)

"${CMD[@]}"

# --mount type=bind,source=$HOME_DIR/.config/github-copilot,target=/root/.config/github-copilot \
