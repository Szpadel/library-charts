{{/*
Ports included by the controller.
*/}}
{{- define "common.controller.ports" -}}
  {{- $ports := list -}}
  {{- $controllerSelectorLabels := deepCopy .Values.controller.selectorLabels -}}
  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.controller -}}
      {{- $controllerSelectorLabels = deepCopy (default $.Values.controller.selectorLabels .selectorLabels) -}}
    {{- end -}}
  {{ end -}}
  {{- range deepCopy .Values.service -}}
    {{- if .enabled -}}
      {{- $serviceSelectorLabels := default $controllerSelectorLabels .selectorLabels -}}
      {{- $mergedSelectedLabels := merge (deepCopy $serviceSelectorLabels) $controllerSelectorLabels -}}
      {{- if deepEqual $controllerSelectorLabels $mergedSelectedLabels -}}
        {{- range $name, $port := .ports -}}
          {{- $_ := set $port "name" $name -}}
          {{- $ports = append $ports $port -}}
        {{- end }}
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
