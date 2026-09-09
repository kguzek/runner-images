#!/bin/sh

set -eu

: "${REGISTRY_HOSTNAME:?}" \
  "${PROJECT_NAME:?}"      \
  "${REPOSITORY_NAME:?}"

IMAGE_CREATED=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
IMAGE_VERSION=$(date -u +'v%y.%m.%d')
IMAGE_REVISION=$(git rev-parse HEAD)

LATEST_MATCHING_VERSION=$(
  skopeo list-tags "docker://$REGISTRY_HOSTNAME/$PROJECT_NAME/$REPOSITORY_NAME" | \
  jq -r ".Tags[] | select(startswith(\"$IMAGE_VERSION\"))"                      | \
  sort --numeric-sort --reverse                                                 | \
  head --lines 1
)

if [ -n "$LATEST_MATCHING_VERSION" ]; then
  SUFFIX="${LATEST_MATCHING_VERSION#"$IMAGE_VERSION"}"
  if [ -z "$SUFFIX" ]; then
    PREVIOUS_REVISION="0"
  else
    PREVIOUS_REVISION="${SUFFIX#-}"
  fi
  IMAGE_VERSION="$IMAGE_VERSION-$(( PREVIOUS_REVISION + 1 ))"
fi

echo "IMAGE_CREATED=$IMAGE_CREATED"
echo "IMAGE_VERSION=$IMAGE_VERSION"
echo "IMAGE_REVISION=$IMAGE_REVISION"
