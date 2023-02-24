{{/*
Ports included by the controller.
*/}}
{{- define "common.controller.ports" -}}
  {{- $ports := list -}}
  {{- $selectorLabels := deepCopy .Values.controller.selectorLabels -}}
  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.controller -}}
      {{- $selectorLabels = deepCopy .selectorLabels -}}
    {{- end -}}
  {{ end -}}

  {{- range deepCopy .Values.service -}}
    {{- $serviceSelectorLabels := default $selectorLabels .selectorLabels -}}
    {{- with (merge $serviceSelectorLabels (include "common.labels.selectorLabels" $ | fromYaml)) }}
      {{- $serviceSelectorLabels := deepCopy (default $selectorLabels .selectorLabels) -}}
    {{- end -}}
    {{- $mergedSelectedLabels := merge (deepCopy $serviceSelectorLabels) $selectorLabels -}}
    {{- if and .enabled (deepEqual (merge (deepCopy $selectorLabels) (include "common.labels.selectorLabels" $ | fromYaml)) $mergedSelectedLabels) -}}
      {{- range $name, $port := .ports -}}
        {{- $_ := set $port "name" $name -}}
        {{- $ports = mustAppend $ports $port -}}
      {{- end }}
    {{- end }}
  {{- end }}

{{/* export/render the list of ports */}}
{{- if $ports -}}
{{- range $_ := $ports }}
{{- if .enabled }}
- name: {{ .name }}
  {{- if and .targetPort (kindIs "string" .targetPort) }}
  {{- fail (printf "Our charts do not support named ports for targetPort. (port name %s, targetPort %s)" .name .targetPort) }}
  {{- end }}
  containerPort: {{ .targetPort | default .port }}
  {{- if .protocol }}
  {{- if or ( eq .protocol "HTTP" ) ( eq .protocol "HTTPS" ) ( eq .protocol "TCP" ) }}
  protocol: TCP
  {{- else }}
  protocol: {{ .protocol }}
  {{- end }}
  {{- else }}
  protocol: TCP
  {{- end }}
{{- end}}
{{- end -}}
{{- end -}}
{{- end -}}
