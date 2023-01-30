{{- /* The main container included in the controller */ -}}
{{- define "common.controller.mainContainer" -}}
  {{- $fullName := include "common.names.fullname" . -}}
  {{- $containerName := $fullName -}}
  {{- $values := .Values.controller -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.controller -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $containerName = printf "%v-%v" $containerName $values.nameOverride -}}
  {{- end -}}


  {{- $repository := default .Values.image.repository $values.image.repository -}}
  {{- $tag := default .Values.image.tag $values.image.tag -}}
  {{- $pullPolicy := default .Values.image.pullPolicy $values.image.pullPolicy -}}
- name: {{ $containerName }}
  image: {{ printf "%s:%s" $repository (default .Chart.AppVersion $tag) | quote }}
  imagePullPolicy: {{ $pullPolicy }}
  {{- with $values.command }}
  command:
    {{- if kindIs "string" . }}
    - {{ tpl . $ }}
    {{- else }}
      {{ tpl (toYaml .) $ | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with $values.args }}
  args:
    {{- if kindIs "string" . }}
    - {{ tpl . $ }}
    {{- else }}
    {{ (tpl (toYaml .) $) | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.lifecycle }}
  lifecycle:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.termination.messagePath }}
  terminationMessagePath: {{ . }}
  {{- end }}
  {{- with .Values.termination.messagePolicy }}
  terminationMessagePolicy: {{ . }}
  {{- end }}

  {{- with (merge .Values.env (default dict $values.env)) }}
  env:
    {{- get (fromYaml (include "common.controller.env_vars" $)) "env" | toYaml | nindent 4 -}}
  {{- end }}
  {{- $envFrom := concat .Values.envFrom (default list $values.envFrom) -}}
  {{- $secret := merge .Values.secret (default dict $values.secret) -}}
  {{- if or $envFrom $secret }}
  envFrom:
    {{- with $envFrom }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- if $secret }}
    - secretRef:
        name: {{ include "common.names.fullname" . }}
    {{- end }}
  {{- end }}
  ports:
  {{- include "common.controller.ports" . | trim | default "[]" | nindent 4 }}
  {{- with (include "common.controller.volumeMounts" . | trim) }}
  volumeMounts:
    {{- nindent 4 . }}
  {{- end }}
  {{- include "common.controller.probes" . | trim | nindent 2 }}
  {{- with .Values.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}
