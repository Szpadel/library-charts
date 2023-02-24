{{/*
This template serves as the blueprint for the CronJob objects that are created
within the common library.
*/}}
{{- define "common.classes.cronjob" -}}
  {{- $fullName := include "common.names.fullname" . -}}
  {{- $jobName := $fullName -}}
  {{- $values := dict -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.controller -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $jobName = printf "%v-%v" $jobName $values.nameOverride -}}
  {{- end -}}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ $jobName | quote }}
  {{- with (merge (deepCopy ($values.labels | default dict)) (include "common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge (deepCopy ($values.annotations | default dict)) (include "common.annotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  concurrencyPolicy: {{ $values.concurrencyPolicy | default "Forbid" | quote }}
  failedJobsHistoryLimit: {{ $values.failedJobsHistoryLimit | default 1 }}
  successfulJobsHistoryLimit: {{ $values.successfulJobsHistoryLimit | default 1 }}
  schedule: {{ required "schedule is required for cronjob" $values.schedule | quote }}
  jobTemplate:
    metadata:
      name: {{ $jobName | quote }}
      {{- with (merge (deepCopy ($values.labels | default dict)) (include "common.labels" $ | fromYaml)) }}
      labels: {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with (merge (deepCopy ($values.annotations | default dict)) (include "common.annotations" $ | fromYaml)) }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    spec:
      template:
        metadata:
          name: {{ $jobName }}
          {{- with (merge (deepCopy ($values.labels | default dict)) (include "common.labels" $ | fromYaml)) }}
          labels: {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with include ("common.podAnnotations") . }}
          annotations:
            {{- . | nindent 12 }}
          {{- end }}
        spec:
          restartPolicy: {{ $values.restartPolicy | default "OnFailure" }}
          {{- include "common.controller.pod" . | nindent 10 }}
{{- end -}}
