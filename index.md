# Trickster Helm Repository

![Trickster](https://helm.tricksterproxy.io/img/trickster-horizontal.png)

Trickster is an HTTP Reverse Proxy Cache and Time Series Database Accelerator.

Our main repo, including documentation, is at <https://github.com/Comcast/trickster>.

Trickster is Open Source Software, licensed under the Apache 2.0 License

## Add the Trickster Helm repository

```bash
helm repo add tricksterproxy https://helm.tricksterproxy.io
```

## Install Trickster

```bash
helm upgrade -i trickster tricksterproxy/trickster
```

For more details on installing Trickster please see the [chart's README](https://github.com/tricksterproxy/helm-charts/tree/master/charts/trickster).
