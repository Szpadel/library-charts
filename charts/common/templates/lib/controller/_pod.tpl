{{- /*
The pod definition included in the controller.
*/ -}}
{{- define "common.controller.pod" -}}
  {{- $values := .Values.controller -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.controller -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- $controllerImage := default dict $values.image -}}
  {{- $repository := pluck "repository" $controllerImage .Values.image | first -}}
  {{- $tag := pluck "tag" $controllerImage .Values.image | first -}}
  {{- $pullPolicy := pluck "pullPolicy" $controllerImage .Values.image | first -}}

  {{- with .Values.imagePullSecrets }}
imagePullSecrets:
    {{- toYaml . | nindent 2 }}
  {{- end }}
serviceAccountName: {{ include "common.names.serviceAccountName" . }}
automountServiceAccountToken: {{ .Values.automountServiceAccountToken | default false }}
  {{- with .Values.podSecurityContext }}
securityContext:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .Values.priorityClassName }}
priorityClassName: {{ . }}
  {{- end }}
  {{- with .Values.runtimeClassName }}
runtimeClassName: {{ . }}
  {{- end }}
  {{- with .Values.schedulerName }}
schedulerName: {{ . }}
  {{- end }}
  {{- with .Values.hostNetwork }}
hostNetwork: {{ . }}
  {{- end }}
  {{- with .Values.hostname }}
hostname: {{ . }}
  {{- end }}
  {{- if .Values.dnsPolicy }}
dnsPolicy: {{ .Values.dnsPolicy }}
  {{- else if .Values.hostNetwork }}
dnsPolicy: ClusterFirstWithHostNet
  {{- else }}
dnsPolicy: ClusterFirst
  {{- end }}
  {{- with .Values.dnsConfig }}
dnsConfig:
    {{- toYaml . | nindent 2 }}
  {{- end }}
enableServiceLinks: {{ .Values.enableServiceLinks }}
  {{- with .Values.termination.gracePeriodSeconds }}
terminationGracePeriodSeconds: {{ . }}
  {{- end }}
initContainers:
  {{- $initContainers := list }}
  {{- $definedInitContainers := mergeOverwrite (deepCopy .Values.initContainers) ($values.initContainers | default dict) -}}
  {{- range $index, $key := (keys $definedInitContainers | uniq | sortAlpha) }}
    {{- $container := get $definedInitContainers $key }}
    {{- if or (not (hasKey $container "enabled")) $container.enabled -}}
      {{- $_ := unset $container "enabled" -}}
      {{- if eq $container.image "inherit" -}}
        {{- $_ := set $container "image" (printf "%s:%s" $repository (default $.Chart.AppVersion $tag)) -}}
        {{- $_ := set $container "imagePullPolicy" ($pullPolicy | default "IfNotPresent") -}}
      {{- end -}}
      {{- if $container.inheritEnv -}}
        {{- $_ := set $container "env" (merge (deepCopy $.Values.env) (deepCopy ($values.env | default dict)) ($container.env | default dict)) -}}
      {{- end -}}
      {{- $_ := unset $container "inheritEnv" -}}
      {{- if not $container.name -}}
        {{- $_ := set $container "name" $key }}
      {{- end }}
      {{- if $container.env -}}
        {{- $_ := set $ "ObjectValues" (dict "env" $container.env) -}}
        {{- $newEnv := fromYaml (include "common.controller.env_vars" $) -}}
        {{- $_ := unset $.ObjectValues "env" -}}
        {{- $_ := set $container "env" $newEnv.env }}
      {{- end }}
      {{- $initContainers = append $initContainers $container }}
    {{- end -}}
  {{- end }}
  {{- tpl (toYaml $initContainers) $ | nindent 2 }}
containers:
  {{- $_ := set . "ObjectValues" (dict "controller" $values) -}}
  {{- include "common.controller.mainContainer" . | nindent 2 }}
  {{- $_ := unset .ObjectValues "controller" -}}
  {{- with (mergeOverwrite (deepCopy .Values.additionalContainers) ($values.additionalContainers | default dict)) }}
    {{- $additionalContainers := list }}
    {{- range $name, $container := . }}
      {{- if or (not (hasKey $container "enabled")) $container.enabled -}}
        {{- $_ := unset $container "enabled" -}}
        {{- if eq $container.image "inherit" -}}
          {{- $_ := set $container "image" (printf "%s:%s" $repository (default $.Chart.AppVersion $tag)) -}}
          {{- $_ := set $container "imagePullPolicy" ($pullPolicy | default "IfNotPresent") -}}
        {{- end -}}
        {{- if $container.inheritEnv -}}
          {{- $_ := set $container "env" (merge $.Values.env ($values.env | default dict) ($container.env | default dict)) -}}
        {{- end -}}
        {{- $_ := unset $container "inheritEnv" -}}
        {{- if not $container.name -}}
          {{- $_ := set $container "name" $name }}
        {{- end }}
        {{- if $container.env -}}
          {{- $_ := set $ "ObjectValues" (dict "env" $container.env) -}}
          {{- $newEnv := fromYaml (include "common.controller.env_vars" $) -}}
          {{- $_ := set $container "env" $newEnv.env }}
          {{- $_ := unset $.ObjectValues "env" -}}
        {{- end }}
        {{- $additionalContainers = append $additionalContainers $container }}
      {{- end -}}
    {{- end }}
    {{- tpl (toYaml $additionalContainers) $ | nindent 2 }}
  {{- end }}
  {{- $_ := set $ "ObjectValues" (dict "controller" $values) -}}
  {{- with (include "common.controller.volumes" . | trim) }}
volumes:
    {{- nindent 2 . }}
  {{- end }}
  {{- $_ := unset $.ObjectValues "controller" }}
  {{- with .Values.hostAliases }}
hostAliases:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .Values.nodeSelector }}
nodeSelector:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .Values.affinity }}
affinity:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .Values.topologySpreadConstraints }}
topologySpreadConstraints:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .Values.tolerations }}
tolerations:
    {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end -}}
