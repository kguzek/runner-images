# Runner Images

This is a set of OCI images for use by Forgejo Actions runners on my [personal Git forge](https://git.guzek.uk).

## Images

1. `node-debian` - referred to by label `ubuntu-latest`. Built to balance compatibility with GitHub Actions' `ubuntu-latest` against low image size. Based on Debian and comes with Node.js to support actions like [actions/checkout](https://code.forgejo.org/actions/checkout) which rely on it.
