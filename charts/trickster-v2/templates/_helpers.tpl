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
