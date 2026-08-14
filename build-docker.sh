#!/bin/bash

set -e

REGISTRY="${REGISTRY:-docker.io}"
IMAGE_NAME="${IMAGE_NAME:-devops-playground}"
ENVIRONMENT="${1:-dev}"

case "$ENVIRONMENT" in
  dev|staging|prod)
    echo "Building Docker image for $ENVIRONMENT..."
    docker build -t "$REGISTRY/$IMAGE_NAME:$ENVIRONMENT" \
                 --build-arg ENVIRONMENT="$ENVIRONMENT" \
                 .
    echo "✅ Image built: $REGISTRY/$IMAGE_NAME:$ENVIRONMENT"
    ;;
  *)
    echo "❌ Usage: $0 {dev|staging|prod}"
    exit 1
    ;;
esac
