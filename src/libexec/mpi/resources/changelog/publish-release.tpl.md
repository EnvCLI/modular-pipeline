{{ range .Versions }}
# {{ if .Tag.Previous }}[{{ .Tag.Name }}]{{ else }}{{ .Tag.Name }}{{ end }} - {{ datetime "02.01.2006" .Tag.Date }}

{{ range .CommitGroups -}}
## {{ .Title }}
{{ range .Commits -}}
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject }}
{{ end }}
{{ end -}}

{{- if .NoteGroups -}}
{{ range .NoteGroups -}}
## {{ .Title }}
{{ range .Notes }}
{{ .Body }}
{{ end }}
{{ end -}}
{{ end -}}
{{ end -}}
