#!/bin/bash

# Exit when any command fails:
set -e

echo "Stopping existing Docker containers..."
docker-compose down

echo "Starting Docker 'reverse-proxy' container..."
docker-compose up -d reverse-proxy
