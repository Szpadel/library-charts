{{/*
This template serves as the blueprint for the DaemonSet objects that are created
within the common library.
*/}}
{{- define "common.classes.daemonset" }}
  {{- $fullName := include "common.names.fullname" . -}}
  {{- $daemonsetName := $fullName -}}
  {{- $values := .Values.controller -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.controller -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $daemonsetName = printf "%v-%v" $daemonsetName $values.nameOverride -}}
  {{- end -}}
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: {{ $daemonsetName }}
  {{- with (merge (deepCopy ($values.labels | default dict)) (include "common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge (deepCopy ($values.annotations | default dict)) (include "common.annotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  revisionHistoryLimit: {{ $values.revisionHistoryLimit }}
  selector:
    {{- with (merge (deepCopy ($values.selectorLabels | default dict)) (include "common.labels.selectorLabels" . | fromYaml)) }}
    matchLabels: {{- toYaml . | nindent 6 }}
    {{- end }}
  template:
    metadata:
      {{- with include ("common.podAnnotations") . }}
      annotations:
        {{- . | nindent 8 }}
      {{- end }}
      labels:
        {{- with (merge (deepCopy ($values.selectorLabels | default dict)) (include "common.labels.selectorLabels" . | fromYaml)) }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- $_ := set . "ObjectValues" (dict "controller" $values) -}}
      {{- include "common.controller.pod" . | nindent 6 }}
      {{- $_ := unset .ObjectValues "controller" -}}
{{- end }}
