# Kubernetes Helm Charts for Trickster

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![](https://github.com/tricksterproxy/helm-charts/workflows/Release%20Charts/badge.svg?branch=master)](https://github.com/tricksterproxy/helm-charts/actions)

This functionality is in beta and is subject to change. The code is provided as-is with no warranties. Beta features are not subject to the support SLA of official GA features.

## Usage

Note: the `trickster-v2` helm chart should be compatible with any Trickster v2.x release.

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, query for the latest (v1.x) trickster helm chart:
```console
helm show chart oci://ghcr.io/trickstercache/charts/trickster-v2 --version '^1'
```
Install trickster via:
```console
# install latest chart
helm install trickster oci://ghcr.io/trickstercache/charts/trickster-v2
# install the latest (via semver query)
helm install trickster oci://ghcr.io/trickstercache/charts/trickster-v2 --version '^1'
# install a specific version of the trickster chart
helm install trickster oci://ghcr.io/trickstercache/charts/trickster-v2:1.0.0
```

## Contributing

We'd love to have you contribute! Please refer to our [contribution guidelines](CONTRIBUTING.md) for details.

### Makefile Targets

To facilitate development and testing, we've included a Makefile with a few common targets.

1. Set up local kubernetes cluster via kind: `make setup-kind`
* Installs [prometheus](https://github.com/prometheus/prometheus), [nginx](https://github.com/nginx/nginx), and [openebs](https://github.com/openebs/openebs) into a new [kind](https://github.com/kubernetes-sigs/kind) cluster.

2. Install trickster: `make install`

3. Open a web browser to trickster (proxying Prometheus' query endpoint): `make query`

4. Point your grafana instance at `http://localhost:31209`

## License

[Apache 2.0 License](./LICENSE).
