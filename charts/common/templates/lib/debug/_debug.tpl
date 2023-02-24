{{- define "common.debug.findChange" -}}
    {{- $org := .org -}}
    {{- $new := .new -}}
    {{- $path := .path | default "" -}}
    {{- range $key, $newValue := $new -}}
        {{- $orgValue := get $org $key -}}
        {{- if not (deepEqual $newValue $orgValue ) -}}
            {{- $currentPath := printf "%v.%v" $path $key -}}
            {{- if kindIs "map" $newValue -}}
                {{- include "common.debug.findChange" (dict "org" $orgValue "new" $newValue "path" $currentPath) -}}
            {{- else -}}
                {{ fail (printf "difference at %v, found (%v)%v, expected (%v)%v" $currentPath (kindOf $newValue) $newValue (kindOf $orgValue) $orgValue) }}
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
