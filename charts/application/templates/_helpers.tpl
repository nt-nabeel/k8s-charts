{{/*
Expand the name of the chart.
*/}}
{{- define "application.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "application.fullname" -}}
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

{{- define "application.extra.fullname" -}}
{{- $fullname := include "application.fullname" . }}
{{- printf "%s-%s" $fullname .extra.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "application.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "application.labels" -}}
helm.sh/chart: {{ include "application.chart" . }}
{{ include "application.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "application.extra.labels" -}}
helm.sh/chart: {{ include "application.chart" . }}
{{ include "application.extra.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "application.selectorLabels" -}}
app.kubernetes.io/name: {{ include "application.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
name: {{ include "application.fullname" . }}
type: "application"
{{- end }}

{{- define "application.extra.selectorLabels" -}}
app.kubernetes.io/name: {{ include "application.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
name: {{ include "application.extra.fullname" . }}
type: "application"
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "application.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "application.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate a pod environment variable
*/}}
{{- define "application.env" -}}
{{- $release := .release }}
{{- range $env := .env }}
- name: {{ $env.name }}
  {{- if $env.value }}
  {{- if $env.generatedFromService }}
  value: "{{ $release.Name }}-{{ $env.value }}"
  {{- else }}
  value: {{ $env.value | quote }}
  {{- end }}
  {{- else if $env.valueFrom }}
  valueFrom:
    {{- if $env.valueFrom.secretKeyRef }}
    secretKeyRef:
      {{- if $env.generatedFromService }}
      name: "{{ $release.Name }}-{{ $env.valueFrom.secretKeyRef.name }}"
      {{- else }}
      name: {{ $env.valueFrom.secretKeyRef.name | quote }}
      {{- end }}
      key: {{ $env.valueFrom.secretKeyRef.key | quote }}
    {{- else if $env.valueFrom.configMapKeyRef }}
    configMapKeyRef:
      {{- if $env.generatedFromService }}
      name: "{{ $release.Name }}-{{ $env.valueFrom.configMapKeyRef.name }}"
      {{- else }}
      name: {{ $env.valueFrom.configMapKeyRef.name | quote }}
      {{- end }}
      key: {{ $env.valueFrom.configMapKeyRef.key | quote }}
    {{- else if $env.valueFrom.fieldRef }}
    fieldRef:
      fieldPath: {{ $env.valueFrom.fieldRef.fieldPath | quote }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
