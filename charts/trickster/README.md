# trickster helm chart

## Chart goals / guidelines
- Should support latest Kubernetes version (Starting with 1.30+)
- Should support the latest major version of Trickster
- Should support the latest minor version of Trickster
- Should not overly abstract Trickster configuration file

## Chart capabilities
- Simple integration with Prometheus Operator or Prometheus Annotation-based Service Discovery
- Arbitrary YAML may be included via the `extraYaml` key within a `values.yaml`

## Persistent storage and replicas

`persistentVolume.enabled` is `true` by default. How the volume is provisioned depends on the workload kind:

| `statefulSet.enabled` | Workload | Storage | Multiple replicas |
| --- | --- | --- | --- |
| `false` (default) | Deployment | one PersistentVolumeClaim shared by all pods | only with a `ReadWriteMany` access mode |
| `true` | StatefulSet | one PersistentVolumeClaim per pod (`volumeClaimTemplates`) | yes, with any access mode |

Most cloud storage classes only offer `ReadWriteOnce`, which can be attached to a single pod at a time. To run more than one replica with persistent storage, enable the StatefulSet:

```yaml
replicaCount: 2
statefulSet:
  enabled: true
persistentVolume:
  enabled: true
  size: 90Gi
  storageClass: my-ssd-class
```

The chart refuses to render a Deployment with `replicaCount > 1` (or autoscaling with `maxReplicas > 1`) that would share a single `ReadWriteOnce` claim, since such a release can never become healthy.

When the Deployment does use a `ReadWriteOnce` claim, the chart defaults its update strategy to `Recreate`: a `RollingUpdate` would try to attach the volume to the new pod while the old pod still holds it and hang indefinitely. Set `deploymentStrategy` explicitly to override this.

Switching an existing release between `Deployment` and `StatefulSet` requires deleting the old workload first, because Kubernetes cannot convert one kind into the other. Data in the old shared claim is not migrated to the per-pod claims.
