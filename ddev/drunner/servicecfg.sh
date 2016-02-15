#!/bin/bash
# Service configuration.

# Array for volume containers that are handled by dRunner.
# These can be used in any Docker image that's part of this service.
#
# It's important to preserve the order here for restore of older backups.
# e.g.
# VOLUMES=("/config" "/data")

VOLUMES=("/config")

# Additional containers used by the service. Only set when we have
# multiple containers (e.g. database container...)
# This is the Docker Hub name of the container, e.g. kitematic/minecraft.

EXTRACONTAINERS=( )
