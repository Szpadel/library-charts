{{/*
  Deprecated, kept for compatibility,
  use common.classes.deployment instead
*/}}
{{- define "common.deployment" }}
  {{- include "common.classes.deployment" . | nindent 0 }}
{{- end }}
