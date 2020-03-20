![Trickster](https://helm.tricksterproxy.io/img/trickster-horizontal.png)

Trickster is an HTTP Reverse Proxy Cache and Time Series Database Accelerator.

This is where Trickster hosts its Kubernetes Helm Charts. For more information about Kubernetes, see <https://kubernetes.io>. For more information about Helm, see <https://helm.sh>.

Our main repo, including documentation, is at <https://github.com/tricksterproxy/trickster>.

Trickster is Open Source Software, licensed under the Apache 2.0 License

## Add the Trickster Helm repository

```bash
helm repo add tricksterproxy https://helm.tricksterproxy.io
```

## Search the Trickster Helm repository

```bash
helm search repo tricksterproxy
```

## Install Trickster with Helm

```bash
helm upgrade -i trickster tricksterproxy/trickster
```

For more details on installing Trickster please see the [chart's README](https://github.com/tricksterproxy/helm-charts/tree/master/charts/trickster).
