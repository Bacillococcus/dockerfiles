#!/bin/env bash

# Execute this on dockerfiles root.
# Usage: ../localbuildscript/build.sh $IMAGE_NAME $DOCKERFILE

sudo DOCKER_BUILDKIT=1 docker build -t $1 -f $2 .