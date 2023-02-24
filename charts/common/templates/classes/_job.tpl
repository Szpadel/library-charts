{{/*
This template serves as the blueprint for the Job objects that are created
within the common library.
*/}}
{{- define "common.classes.job" -}}
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
kind: Job
metadata:
  name: {{ $jobName }}
  {{- with (merge (deepCopy ($values.labels | default dict)) (include "common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge (deepCopy ($values.annotations | default dict)) (include "common.annotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  template:
    metadata:
      name: {{ $jobName }}
      {{- with (merge (deepCopy ($values.labels | default dict)) (include "common.labels" $ | fromYaml)) }}
      labels: {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with include ("common.podAnnotations") . }}
      annotations:
        {{- . | nindent 8 }}
      {{- end }}
    spec:
      restartPolicy: {{ $values.restartPolicy | default "OnFailure" }}
      {{- include "common.controller.pod" . | nindent 6 }}
{{- end -}}
