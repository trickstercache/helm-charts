# trickster helm chart

## Chart goals / guidelines
- Should support latest Kubernetes version (Starting with 1.30+)
- Should support the latest major version of Trickster
- Should support the latest minor version of Trickster
- Should not overly abstract Trickster configuration file

## Chart capabilities
- Simple integration with Prometheus Operator or Prometheus Annotation-based Service Discovery
- Arbitrary YAML may be included via the `extraYaml` key within a `values.yaml`
