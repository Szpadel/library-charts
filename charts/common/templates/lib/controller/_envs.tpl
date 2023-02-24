{{- /* The envs included in the controller */ -}}
{{- define "common.controller.envs" -}}
  {{- $values := .Values.controller -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.controller -}}
      {{- $values = . -}}
    {{- end -}}
  {{- end -}}

  {{- with (mergeOverwrite (deepCopy .Values.env) (default dict $values.env)) }}
env:
  {{- $_ := set $ "ObjectValues" (dict "env" .) -}}
  {{- get (fromYaml (include "common.controller.env_vars" $)) "env" | toYaml | nindent 2 -}}
  {{- $_ := unset $.ObjectValues "env" -}}

  {{- end }}
  {{- $envFrom := concat .Values.envFrom (default list $values.envFrom) -}}
  {{- $secret := merge (deepCopy .Values.secret) (default dict $values.secret) -}}
  {{- if or $envFrom $secret }}
envFrom:
    {{- with $envFrom }}
      {{- toYaml . | nindent 2 }}
    {{- end }}
    {{- if $secret }}
  - secretRef:
      name: {{ include "common.names.fullname" . }}
    {{- end }}
  {{- end }}
{{- end -}}
