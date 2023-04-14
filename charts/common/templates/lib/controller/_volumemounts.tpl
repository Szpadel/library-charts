{{/* Volumes included by the controller */}}
{{- define "common.controller.volumeMounts" -}}
  {{- $values := .Values.controller -}}
  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.controller -}}
      {{- $values = . -}}
    {{- end -}}
  {{- end -}}

  {{- $persistence := mergeOverwrite (deepCopy .Values.persistence) ($values.persistence | default dict) }}
  {{- if eq $values._inherit false -}}
    {{- $persistence = deepCopy (default dict $values.persistence) -}}
  {{- end -}}
  {{- $_ := unset $persistence "_inherit" -}}
  {{- range $persistenceIndex, $persistenceItem := $persistence }}
    {{- $autoMountDefined := kindIs "bool" $persistenceItem.autoMount -}}
    {{- $autoMount := or (not $autoMountDefined) $persistenceItem.autoMount -}}
    {{- if and $persistenceItem.enabled $autoMount -}}
      {{- if kindIs "slice" $persistenceItem.subPath -}}
        {{- if $persistenceItem.mountPath -}}
          {{- fail (printf "Cannot use persistence.mountPath with a subPath list (%s)" $persistenceIndex) }}
        {{- end -}}
        {{- range $subPathIndex, $subPathItem := $persistenceItem.subPath }}
- name: {{ $persistenceIndex }}
  subPath: {{ required "subPaths as a list of maps require a path field" $subPathItem.path }}
  mountPath: {{ required "subPaths as a list of maps require an explicit mountPath field" $subPathItem.mountPath }}
          {{- with $subPathItem.readOnly }}
  readOnly: {{ . }}
          {{- end }}
          {{- with $subPathItem.mountPropagation }}
  mountPropagation: {{ . }}
          {{- end }}
        {{- end -}}
      {{- else -}}
        {{/* Set the default mountPath to /<name_of_the_peristence_item> */}}
        {{- $mountPath := (printf "/%v" $persistenceIndex) -}}
        {{- if eq "hostPath" (default "pvc" $persistenceItem.type) -}}
          {{- $mountPath = $persistenceItem.hostPath -}}
        {{- end -}}
        {{/* Use the specified mountPath if provided */}}
        {{- with $persistenceItem.mountPath -}}
          {{- $mountPath = . -}}
        {{- end }}
        {{- if ne $mountPath "-" }}
- name: {{ $persistenceIndex }}
  mountPath: {{ $mountPath }}
          {{- with $persistenceItem.subPath }}
  subPath: {{ . }}
          {{- end }}
          {{- with $persistenceItem.readOnly }}
  readOnly: {{ . }}
          {{- end }}
          {{- with $persistenceItem.mountPropagation }}
  mountPropagation: {{ . }}
          {{- end }}
        {{- end }}
      {{- end -}}
    {{- end -}}
  {{- end }}

  {{- if eq $values.type "statefulset" }}
    {{- range $index, $vct := $values.volumeClaimTemplates }}
- mountPath: {{ $vct.mountPath }}
  name: {{ $vct.name }}
      {{- if $vct.subPath }}
  subPath: {{ $vct.subPath }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}
