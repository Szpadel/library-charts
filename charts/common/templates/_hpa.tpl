{{/*
Renders all hpa required by the chart.
*/}}
{{- define "common.hpa" -}}

  {{- range $name, $hpa := .Values.autoscaling -}}
    {{- if $hpa.enabled -}}

      {{- $hpaValues := deepCopy $hpa -}}

      {{/* set the default nameOverride to the hpa name */}}
      {{- if not $hpaValues.nameOverride -}}
        {{- $_ := set $hpaValues "nameOverride" $name -}}
      {{ end -}}

      {{- $_ := set $ "ObjectValues" (dict "autoscaling" $hpaValues) -}}
      {{- include "common.classes.hpa" $ -}}
      {{- $_ := unset $.ObjectValues "autoscaling" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
