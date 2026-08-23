# Runner Images

This is a set of OCI images for use by Forgejo Actions runners on my [personal Git forge](https://git.guzek.uk).

## Images

1. [node-debian](./node-debian/Containerfile): a generic runner image labelled as `ubuntu-latest`. Built to balance compatibility with GitHub Actions' `ubuntu-latest` against low image size. Based on Debian and comes with Node.js to support actions like [actions/checkout](https://git.guzek.uk/actions/checkout) which rely on it.

## Copyright

The code in this repository is licensed under the [MIT License](./LICENSE).

It contains fragments of code from <https://github.com/Frozen-Tapestry/runner-images>, which is also licensed under the [MIT License](./LICENSES/LICENSE.catthehacker).
