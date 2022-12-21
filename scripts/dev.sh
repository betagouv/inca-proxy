#!/bin/bash

# Exit when any command fails:
set -e

echo "Stopping existing Docker containers..."
docker compose down -v

echo "Creating \"proxy\" network if doesn't exist..."
docker network inspect proxy >/dev/null 2>&1 || docker network create proxy

echo "Starting Docker 'reverse-proxy' container..."
docker compose up reverse-proxy
