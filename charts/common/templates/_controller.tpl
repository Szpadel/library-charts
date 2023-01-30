{{/*
Renders all controllers required by the chart.
*/}}
{{- define "common.controller" -}}

  {{/* Render default controller */}}
  {{- include "common.classes.controller" . -}}

  {{/* Render additional controllers */}}
  {{- range $name, $controller := .Values.additionalControllers -}}
    {{- if $controller.enabled -}}

      {{- $controllerValues := $controller -}}

      {{/* set the default nameOverride to the controller name */}}
      {{- if not $controllerValues.nameOverride -}}
        {{- $_ := set $controllerValues "nameOverride" $name -}}
      {{ end -}}

      {{- $_ := set $ "ObjectValues" (dict "controller" $controllerValues) -}}
      {{- include "common.classes.controller" $ -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
