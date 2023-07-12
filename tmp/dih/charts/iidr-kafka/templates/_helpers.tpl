
{{/*
Return the proper Docker Image Registry Secret Names extracted from global.imagePullSecrets
*/}}
{{- define "di.imagePullSecrets" -}}
  {{- $pullSecrets := list }}

  {{- if .Values.global }}
    {{- range .Values.global.imagePullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- end -}}

  {{- if (not (empty $pullSecrets)) }}
imagePullSecrets:
    {{- range $pullSecrets }}
  - name: {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}