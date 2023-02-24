{{/*
This template serves as a blueprint for all controller objects that are created
within the common library.
*/}}
{{- define "common.classes.controller" -}}
  {{- $values := deepCopy .Values.controller -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.controller -}}
      {{- $values = . -}}
    {{- end -}}
    {{- $_ := unset .ObjectValues "controller" -}}
  {{ end -}}

  {{- if $values.enabled }}
    {{- $_ := set $ "ObjectValues" (dict "controller" $values) -}}
    {{- if eq $values.type "deployment" }}
      {{- include "common.classes.deployment" $ | nindent 0 }}
    {{ else if eq $values.type "daemonset" }}
      {{- include "common.classes.daemonset" $ | nindent 0 }}
    {{ else if eq $values.type "statefulset"  }}
      {{- include "common.classes.statefulset" $ | nindent 0 }}
    {{ else if eq $values.type "job"  }}
      {{- include "common.classes.job" $ | nindent 0 }}
    {{ else if eq $values.type "cronjob"  }}
      {{- include "common.classes.cronjob" $ | nindent 0 }}
    {{ else }}
      {{- fail (printf "Not a valid controller.type (%s)" $values.type) }}
    {{- end -}}
    {{- $_ := unset $.ObjectValues "controller" -}}
  {{- end -}}
{{- end -}}
