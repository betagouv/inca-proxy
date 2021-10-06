#!/bin/bash

# Exit when any command fails:
set -e

echo "Stopping existing Docker containers..."
docker-compose down

echo "Starting Docker 'app' container..."
docker-compose up -d app
