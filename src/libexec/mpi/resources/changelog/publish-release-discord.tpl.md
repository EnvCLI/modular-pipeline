{{ range .Versions }}
:rocket: ***{{ .Tag.Name }}*** - {{ datetime "02.01.2006" .Tag.Date }} :rocket:
<https://github.com/twitch4j/twitch4j/releases/tag/{{ .Tag.Name }}>

{{ range .CommitGroups -}}
**{{ .Title }}**
{{ range .Commits -}}
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject }}
{{ end }}
{{ end -}}

{{- if .NoteGroups -}}
{{ range .NoteGroups -}}
**{{ .Title }}**
{{ range .Notes }}
{{ .Body }}
{{ end }}
{{ end -}}
{{ end -}}
{{ end -}}
