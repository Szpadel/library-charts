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
  {{- $definedInitContainers := merge .Values.initContainers ($values.initContainers | default dict) -}}
  {{- range $index, $key := (keys $definedInitContainers | uniq | sortAlpha) }}
    {{- $container := get $definedInitContainers $key }}
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
  {{- end }}
  {{- tpl (toYaml $initContainers) $ | nindent 2 }}
containers:
  {{- include "common.controller.mainContainer" . | nindent 2 }}
  {{- with (merge .Values.additionalContainers ($values.additionalContainers | default dict)) }}
    {{- $additionalContainers := list }}
    {{- range $name, $container := . }}
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
    {{- end }}
    {{- tpl (toYaml $additionalContainers) $ | nindent 2 }}
  {{- end }}
  {{- with (include "common.controller.volumes" . | trim) }}
volumes:
    {{- nindent 2 . }}
  {{- end }}
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
