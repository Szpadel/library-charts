{{/*
The Secret object to be created.
*/}}
{{- define "common.secret" }}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "common.names.fullname" . }}
  labels: {{- include "common.labels" $ | nindent 4 }}
  annotations: {{- include "common.annotations" $ | nindent 4 }}
type: Opaque
{{- with .Values.secret }}
stringData:
  {{- tpl (toYaml .) $ | nindent 2 }}
{{- end }}
{{- end }}
