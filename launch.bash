#!/bin/bash
set -euo pipefail

PROGRAM=${1}
FILE="${PROGRAM}.cu"
EXECUTABLE="${PROGRAM}_cuda"
PROFILE="${EXECUTABLE}_profile"

nvcc "$FILE" -o "$EXECUTABLE"
nsys profile --output="$PROFILE" --force-overwrite true "$EXECUTABLE" && nsys stats --force-export=true "${PROFILE}.nsys-rep"