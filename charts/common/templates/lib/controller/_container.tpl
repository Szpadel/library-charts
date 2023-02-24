{{- /* The main container included in the controller */ -}}
{{- define "common.controller.mainContainer" -}}
  {{- $fullName := include "common.names.fullname" . -}}
  {{- $containerName := $fullName -}}
  {{- $values := deepCopy .Values.controller -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.controller -}}
      {{- $values = . -}}
    {{- end -}}
  {{- end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $containerName = printf "%v-%v" $containerName $values.nameOverride -}}
  {{- end -}}


  {{- $controllerImage := default dict $values.image -}}
  {{- $repository := pluck "repository" $controllerImage .Values.image | first -}}
  {{- $tag := pluck "tag" $controllerImage .Values.image | first -}}
  {{- $pullPolicy := pluck "pullPolicy" $controllerImage .Values.image | first -}}
- name: {{ $containerName }}
  image: {{ printf "%s:%s" $repository (default .Chart.AppVersion $tag) | quote }}
  imagePullPolicy: {{ $pullPolicy | default "IfNotPresent" }}
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

  {{- $_ := set $ "ObjectValues" (dict "controller" $values) -}}
  {{- include "common.controller.envs" . | nindent 2 -}}
  {{- $_ := unset $.ObjectValues "controller" }}
  ports:
  {{- include "common.controller.ports" . | trim | default "[]" | nindent 4 }}
  {{- $_ := set $ "ObjectValues" (dict "controller" $values) -}}
  {{- with (include "common.controller.volumeMounts" . | trim) }}
  volumeMounts:
    {{- nindent 4 . }}
  {{- end }}
  {{- $_ := unset $.ObjectValues "controller" }}
  {{- $_ := set $ "ObjectValues" (dict "controller" $values) -}}
  {{- include "common.controller.probes" . | trim | nindent 2 }}
  {{- $_ := unset $.ObjectValues "controller" }}
  {{- with .Values.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}
