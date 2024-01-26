{{/*
Renders the Persistent Volume Claim objects required by the chart.
*/}}
{{- define "common.pvc" -}}
  {{- /* Generate pvc as required */ -}}
  {{- range $index, $PVC := .Values.persistence }}
    {{- $enabledByController := dig "controller" "persistence" $index "enabled" false $.Values  -}}
    {{- range $_, $additionalController := $.Values.additionalControllers -}}
      {{- $controllerEnabled := dig "enabled" false $additionalController -}}
      {{- $persistenceEnabled := dig "persistence" $index "enabled" false $additionalController -}}
      {{- if and $controllerEnabled $persistenceEnabled -}}
        {{- $enabledByController = true -}}
      {{- end -}}
    {{- end -}}


    {{- if and (or $PVC.enabled $enabledByController) (eq (default "pvc" $PVC.type) "pvc") (not $PVC.existingClaim) -}}
      {{- $persistenceValues := deepCopy $PVC -}}
      {{- if not $persistenceValues.nameOverride -}}
        {{- $_ := set $persistenceValues "nameOverride" $index -}}
      {{- end -}}
      {{- $_ := set $ "ObjectValues" (dict "persistence" $persistenceValues) -}}
      {{- include "common.classes.pvc" $ | nindent 0 -}}
    {{- end }}
  {{- end }}
{{- end }}
