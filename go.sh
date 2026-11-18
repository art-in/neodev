#!/bin/bash

set -e

PARENT_DIR=$(dirname $(realpath "$0"))

# if docker hub is unavailable - build will fail when loading image metadata.
# in this case just skip building step completely, by commenting it out.
$PARENT_DIR/build.sh $1
$PARENT_DIR/run.sh $1

