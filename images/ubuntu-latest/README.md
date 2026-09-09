# `ubuntu-latest`

A compact Ubuntu 26.04 OCI image for Forgejo Actions runners. It aims to
provide compatibility with GitHub Actions' `ubuntu-latest` environment while
keeping the image size low.

## Installed software

- Ubuntu 26.04 (`resolute`)
- CA certificates
- Git
- Node.js
- Docker Engine (`docker-ce`)
- Docker Buildx plugin
- Docker Compose plugin
- curl
- wget
- zip
- unzip
- tar
- jq
- containerd
- gettext-base (`envsubst`)

## Trivia

The image layers are intentionally not fully optimized in order to keep individual layer sizes below 100 MB. This might mean more frequent cache misses, but since <https://git.guzek.uk> is hosted behind CloudFlare, this is a hard limit that needs to be maintained.
