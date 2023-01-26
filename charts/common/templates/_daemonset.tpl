{{/*
This template serves as the blueprint for the DaemonSet objects that are created
within the common library.
*/}}
{{- define "common.daemonset" }}
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: {{ include "common.names.fullname" . }}
  {{- with (merge (.Values.controller.labels | default dict) (include "common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge (.Values.controller.annotations | default dict) (include "common.annotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  revisionHistoryLimit: {{ .Values.controller.revisionHistoryLimit }}
  selector:
    {{- with (merge (.Values.controller.selectorLabels | default dict) (include "common.labels.selectorLabels" . | fromYaml)) }}
    matchLabels: {{- toYaml . | nindent 6 }}
    {{- end }}
  template:
    metadata:
      {{- with include ("common.podAnnotations") . }}
      annotations:
        {{- . | nindent 8 }}
      {{- end }}
      labels:
        {{- with (merge (.Values.controller.selectorLabels | default dict) (include "common.labels.selectorLabels" . | fromYaml)) }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- include "common.controller.pod" . | nindent 6 }}
{{- end }}
