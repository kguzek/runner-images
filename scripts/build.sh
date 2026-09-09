#!/bin/sh

set -eu

: "${REGISTRY_HOSTNAME:?}" \
  "${PROJECT_NAME:?}"      \
  "${GIT_HOSTNAME:?}"      \
  "${GIT_OWNER:?}"         \
  "${CONTAINER_BACKEND:=docker}"

export REGISTRY_HOSTNAME PROJECT_NAME
FIRST_ARGUMENT="${1:-}"

should_push() {
  [ "$FIRST_ARGUMENT" = '--push' ]
}

for CONTAINERFILE_PATH in ./images/*/Containerfile; do
  REPOSITORY_PATH="${CONTAINERFILE_PATH%/Containerfile}"
  export REPOSITORY_NAME="${REPOSITORY_PATH#./images/}"
  eval "$(./scripts/metadata.sh)"

  TAG_REGISTRY="$REGISTRY_HOSTNAME/$PROJECT_NAME/$REPOSITORY_NAME"
  TAG_GIT="$GIT_HOSTNAME/$GIT_OWNER/$PROJECT_NAME/$REPOSITORY_NAME"

  TAG_REGISTRY_LATEST="$TAG_REGISTRY:latest"
  TAG_REGISTRY_VERSIONED="$TAG_REGISTRY:$IMAGE_VERSION"
  TAG_GIT_LATEST="$TAG_GIT:latest"
  TAG_GIT_VERSIONED="$TAG_GIT:$IMAGE_VERSION"

  "$CONTAINER_BACKEND" build "$REPOSITORY_PATH"        \
    --file "$CONTAINERFILE_PATH"                       \
    --build-arg "REGISTRY_HOSTNAME=$REGISTRY_HOSTNAME" \
    --build-arg "PROJECT_NAME=$PROJECT_NAME"           \
    --build-arg "REPOSITORY_NAME=$REPOSITORY_NAME"     \
    --build-arg "GIT_HOSTNAME=$GIT_HOSTNAME"           \
    --build-arg "GIT_OWNER=$GIT_OWNER"                 \
    --build-arg "IMAGE_CREATED=$IMAGE_CREATED"         \
    --build-arg "IMAGE_VERSION=$IMAGE_VERSION"         \
    --build-arg "IMAGE_REVISION=$IMAGE_REVISION"       \
    --tag "$TAG_REGISTRY_LATEST"                       \
    --tag "$TAG_REGISTRY_VERSIONED"                    \
    --tag "$TAG_GIT_LATEST"                            \
    --tag "$TAG_GIT_VERSIONED"

  if ! should_push; then
    continue
  fi

  for TAG in "$TAG_REGISTRY_LATEST" "$TAG_REGISTRY_VERSIONED" "$TAG_GIT_LATEST" "$TAG_GIT_VERSIONED"; do
    "$CONTAINER_BACKEND" push "$TAG"
  done
  cosign sign --new-bundle-format=false --use-signing-config=false "$TAG_REGISTRY_LATEST"
done
