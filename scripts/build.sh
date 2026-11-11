#!/bin/sh

set -eu

: "${PROJECT_NAME:?}"      \
  "${GIT_HOSTNAME:?}"      \
  "${GIT_OWNER:?}"         \
  "${CONTAINER_BACKEND:=docker}"

export PROJECT_NAME GIT_HOSTNAME GIT_OWNER
FIRST_ARGUMENT="${1:-}"

should_push() {
  [ "$FIRST_ARGUMENT" = '--push' ]
}

should_sign() {
  [ "$FIRST_ARGUMENT" = '--sign' ]
}

for CONTAINERFILE_PATH in ./images/*/Containerfile; do
  REPOSITORY_PATH="${CONTAINERFILE_PATH%/Containerfile}"
  export REPOSITORY_NAME="${REPOSITORY_PATH#./images/}"
  eval "$(./scripts/metadata.sh)"

  TAG_GIT="$GIT_HOSTNAME/$GIT_OWNER/$PROJECT_NAME/$REPOSITORY_NAME"

  TAG_GIT_LATEST="$TAG_GIT:latest"
  TAG_GIT_VERSIONED="$TAG_GIT:$IMAGE_VERSION"

  if should_sign; then
    IMAGE_DIGEST="$(skopeo inspect "docker://$TAG_GIT_LATEST" | jq -r .Digest)"
    cosign sign --new-bundle-format=false --use-signing-config=false "$TAG_GIT_LATEST@$IMAGE_DIGEST"
    continue
  fi

  if should_push; then
    TAG_BUILD="$TAG_GIT_VERSIONED"
  else
    TAG_BUILD="$TAG_GIT:check-${GITHUB_RUN_ID:-$$}"
  fi

  "$CONTAINER_BACKEND" build "$REPOSITORY_PATH"        \
    --file "$CONTAINERFILE_PATH"                       \
    --build-arg "PROJECT_NAME=$PROJECT_NAME"           \
    --build-arg "REPOSITORY_NAME=$REPOSITORY_NAME"     \
    --build-arg "GIT_HOSTNAME=$GIT_HOSTNAME"           \
    --build-arg "GIT_OWNER=$GIT_OWNER"                 \
    --build-arg "IMAGE_CREATED=$IMAGE_CREATED"         \
    --build-arg "IMAGE_VERSION=$IMAGE_VERSION"         \
    --build-arg "IMAGE_REVISION=$IMAGE_REVISION"       \
    --tag "$TAG_BUILD"

  if ! should_push; then
    "$CONTAINER_BACKEND" image rm "$TAG_BUILD" > /dev/null
    continue
  fi

  "$CONTAINER_BACKEND" tag "$TAG_GIT_VERSIONED" "$TAG_GIT_LATEST"

  for TAG in "$TAG_GIT_VERSIONED" "$TAG_GIT_LATEST"; do
    "$CONTAINER_BACKEND" push "$TAG"
  done
done
