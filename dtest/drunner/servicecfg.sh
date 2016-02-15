#!/bin/bash

# Array for volume containers that are handled by dr.
# These can be used in any Docker image that's part of this service.
# It's important to preserve the order here for backup/restore.
VOLUMES=("/config" "/data")

# Containers! 
EXTRACONTAINERS=( "kitematic/minecraft" )
