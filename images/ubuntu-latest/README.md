# `ubuntu-latest`

A compact Ubuntu 26.04 OCI image for Forgejo Actions runners. It aims to
provide compatibility with GitHub Actions' `ubuntu-latest` environment while
keeping the image size low.

## Installed software

- Ubuntu 26.04 (`resolute`)
- CA certificates
- curl
- Docker Engine (`docker-ce`)
- Docker Buildx plugin
- Docker Compose plugin
- containerd
- gettext-base (`envsubst`)
- Git
- jq
- Node.js

## Trivia

The image layers are intentionally not fully optimized in order to keep individual layer sizes below 100 MB. This might mean more frequent cache misses, but since <https://git.guzek.uk> is hosted behind CloudFlare, this is a hard limit that needs to be maintained.
