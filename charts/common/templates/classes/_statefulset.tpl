{{/*
This template serves as the blueprint for the StatefulSet objects that are created
within the common library.
*/}}
{{- define "common.classes.statefulset" }}
  {{- $fullName := include "common.names.fullname" . -}}
  {{- $statefulsetName := $fullName -}}
  {{- $values := .Values.controller -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.controller -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $statefulsetName = printf "%v-%v" $statefulsetName $values.nameOverride -}}
  {{- end -}}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ $statefulsetName }}
  {{- with (merge ($values.labels | default dict) (include "common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge ($values.annotations | default dict) (include "common.annotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  revisionHistoryLimit: {{ $values.revisionHistoryLimit }}
  replicas: {{ $values.replicas | default 1 }}
  podManagementPolicy: {{ default "OrderedReady" $values.podManagementPolicy }}
  {{- $strategy := default "RollingUpdate" $values.strategy }}
  {{- if and (ne $strategy "OnDelete") (ne $strategy "RollingUpdate") }}
    {{- fail (printf "Not a valid strategy type for StatefulSet (%s)" $strategy) }}
  {{- end }}
  updateStrategy:
    type: {{ $strategy }}
    {{- if and (eq $strategy "RollingUpdate") $values.rollingUpdate.partition }}
    rollingUpdate:
      partition: {{ $values.rollingUpdate.partition }}
    {{- end }}
  selector:
    {{- with (merge ($values.selectorLabels | default dict) (include "common.labels.selectorLabels" . | fromYaml)) }}
    matchLabels: {{- toYaml . | nindent 6 }}
    {{- end }}
  serviceName: {{ include "common.names.fullname" . }}
  template:
    metadata:
      {{- with include ("common.podAnnotations") . }}
      annotations:
        {{- . | nindent 8 }}
      {{- end }}
      labels:
        {{- with (merge ($values.selectorLabels | default dict) (include "common.labels.selectorLabels" . | fromYaml)) }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- include "common.controller.pod" . | nindent 6 }}
  volumeClaimTemplates:
    {{- range $index, $vct := .Values.volumeClaimTemplates }}
    - metadata:
        name: {{ $vct.name }}
      spec:
        accessModes:
          - {{ required (printf "accessMode is required for vCT %v" $vct.name) $vct.accessMode  | quote }}
        resources:
          requests:
            storage: {{ required (printf "size is required for PVC %v" $vct.name) $vct.size | quote }}
        {{- if $vct.storageClass }}
        storageClassName: {{ if (eq "-" $vct.storageClass) }}""{{- else }}{{ $vct.storageClass | quote }}{{- end }}
        {{- end }}
    {{- end }}
{{- end }}
