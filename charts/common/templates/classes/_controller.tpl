{{/*
This template serves as a blueprint for all controller objects that are created
within the common library.
*/}}
{{- define "common.classes.controller" -}}
  {{- $values := .Values.controller -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.controller -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- if $values.enabled }}
    {{- if eq $values.type "deployment" }}
      {{- include "common.classes.deployment" . | nindent 0 }}
    {{ else if eq $values.type "daemonset" }}
      {{- include "common.classes.daemonset" . | nindent 0 }}
    {{ else if eq $values.type "statefulset"  }}
      {{- include "common.classes.statefulset" . | nindent 0 }}
    {{ else }}
      {{- fail (printf "Not a valid controller.type (%s)" $values.type) }}
    {{- end -}}
  {{- end -}}
{{- end -}}
