{{/*
Expand the name of the chart.
*/}}
{{- define "trickster.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "trickster.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "trickster.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "trickster.labels" -}}
helm.sh/chart: {{ include "trickster.chart" . }}
{{ include "trickster.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "trickster.selectorLabels" -}}
app.kubernetes.io/name: {{ include "trickster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "trickster.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "trickster.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Inject default values into the config.yaml that correspond with other chart values.
*/}}
{{- define "trickster.config" -}}
{{- $fsCache := dict "filesystem" (dict "cache_path" (.Values.persistentVolume.mountPath | default "/data")) -}}
{{- $bbCache := dict "bbolt" (dict "filename" (printf "%s/trickster.db" (.Values.persistentVolume.mountPath | default "/data"))) -}}
{{- $bdCache := dict "badger" (dict "directory" (.Values.persistentVolume.mountPath | default "/data") "value_directory" (.Values.persistentVolume.mountPath | default "/data")) -}}
{{- $default := merge (merge $fsCache $bbCache) $bdCache -}}
{{- $config := merge (dict "caches" (dict "default" $default)) .Values.config -}}
{{- $config | toYaml -}}
{{- end }}

{{- define "trickster.proxyPort" -}}
{{- $.Values.config.frontend.listen_port }}
{{- end }}

{{- define "trickster.metricsPort" -}}
{{- $.Values.config.metrics.listen_port }}
{{- end}}

{{/*
Workload kind: StatefulSet when statefulSet.enabled, otherwise Deployment.
*/}}
{{- define "trickster.workloadKind" -}}
{{- if .Values.statefulSet.enabled }}StatefulSet{{- else }}Deployment{{- end }}
{{- end }}

{{/*
Name of the headless Service that governs the StatefulSet.
*/}}
{{- define "trickster.headlessServiceName" -}}
{{- printf "%s-headless" (include "trickster.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Returns "true" when the storage volume should be provisioned per pod through the
StatefulSet's volumeClaimTemplates instead of a single shared PersistentVolumeClaim.
*/}}
{{- define "trickster.useVolumeClaimTemplates" -}}
{{- if and .Values.statefulSet.enabled .Values.persistentVolume.enabled (not .Values.persistentVolume.existingClaim) }}true{{- end }}
{{- end }}

{{/*
PersistentVolumeClaim spec shared by the standalone PVC and the StatefulSet volumeClaimTemplates.
*/}}
{{- define "trickster.pvcSpec" -}}
accessModes:
{{ toYaml .Values.persistentVolume.accessModes | indent 2 }}
{{- if .Values.persistentVolume.storageClass }}
{{- if (eq "-" .Values.persistentVolume.storageClass) }}
storageClassName: ""
{{- else }}
storageClassName: "{{ .Values.persistentVolume.storageClass }}"
{{- end }}
{{- end }}
resources:
  requests:
    storage: "{{ .Values.persistentVolume.size }}"
{{- if .Values.persistentVolume.selector }}
selector:
  {{- toYaml .Values.persistentVolume.selector | nindent 2 }}
{{- end }}
{{- if .Values.persistentVolume.volumeName }}
volumeName: "{{ .Values.persistentVolume.volumeName }}"
{{- end }}
{{- end }}

{{/*
Refuse to render a Deployment whose replicas would all have to mount one ReadWriteOnce claim.
Such a release can never become healthy: only one pod can attach the volume at a time.
*/}}
{{- define "trickster.validatePersistence" -}}
{{- if and .Values.persistentVolume.enabled (not .Values.statefulSet.enabled) (not .Values.persistentVolume.existingClaim) (not (has "ReadWriteMany" .Values.persistentVolume.accessModes)) }}
{{- $replicas := ternary (int .Values.autoscaling.maxReplicas) (int .Values.replicaCount) .Values.autoscaling.enabled }}
{{- $source := ternary "autoscaling.maxReplicas" "replicaCount" .Values.autoscaling.enabled }}
{{- if gt $replicas 1 }}
{{- fail (printf "persistentVolume.enabled=true renders a single PersistentVolumeClaim with accessModes %v that every replica of the Deployment would mount, but %s is %d. Only one pod can attach a ReadWriteOnce volume, so the release could never become healthy. Choose one of: set statefulSet.enabled=true so each replica gets its own claim via volumeClaimTemplates; set replicaCount=1 and autoscaling.enabled=false; use a ReadWriteMany storage class and add it to persistentVolume.accessModes; or set persistentVolume.existingClaim to a claim you manage." .Values.persistentVolume.accessModes $source $replicas) }}
{{- end }}
{{- end }}
{{- end }}
