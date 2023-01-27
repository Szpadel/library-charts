{{/*
  Deprecated, kept for compatibility,
  use common.classes.daemonset instead
*/}}
{{- define "common.daemonset" }}
  {{- include "common.classes.daemonset" . | nindent 0 }}
{{- end }}
