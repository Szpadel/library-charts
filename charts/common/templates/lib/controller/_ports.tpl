{{/*
Ports included by the controller.
*/}}
{{- define "common.controller.ports" -}}
  {{- $ports := list -}}
  {{- $selectorLabels := .Values.controller.selectorLabels -}}
  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.controller -}}
      {{- $selectorLabels = .selectorLabels -}}
    {{- end -}}
  {{ end -}}

  {{- range .Values.service -}}
    {{- $serviceSelectorLabels := default $selectorLabels .selectorLabels -}}
    {{- with (merge $serviceSelectorLabels (include "common.labels.selectorLabels" $ | fromYaml)) }}
      {{- $serviceSelectorLabels := default $selectorLabels .selectorLabels -}}
    {{- end -}}
    {{- $mergedSelectedLabels := merge $serviceSelectorLabels $selectorLabels -}}
    {{- if and .enabled (deepEqual $selectorLabels $mergedSelectedLabels) -}}
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
