{{/*
  Deprecated, kept for compatibility,
  use common.classes.statefulset instead
*/}}
{{- define "common.statefulset" }}
  {{- include "common.classes.statefulset" . | nindent 0 }}
{{- end }}
