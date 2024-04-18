{{- define "elasticagent.kubernetes.config.state.nodes.init" -}}
{{- if eq ((.Values.kubernetes.state).enabled) false -}}
{{- $_ := set $.Values.kubernetes.nodes.state "enabled" false -}}
{{- else -}}
{{- if eq $.Values.kubernetes.nodes.state.enabled true -}}
{{- $preset := $.Values.eck_agent.presets.clusterWide -}}
{{- if eq $.Values.kubernetes.state.deployKSM true -}}
{{- $preset = $.Values.eck_agent.presets.ksmSharded -}}
{{- include "elasticagent.preset.applyOnce" (list $ $preset "elasticagent.kubernetes.ksmsharded.preset") -}}
{{- end -}}
{{- $inputVal := (include "elasticagent.kubernetes.config.state.nodes.input" $ | fromYamlArray) -}}
{{- include "elasticagent.preset.mutate.inputs" (list $ $preset $inputVal) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "elasticagent.kubernetes.config.state.nodes.input" -}}
- id: kubernetes/metrics-kubernetes.state_node
  type: kubernetes/metrics
  data_stream:
    namespace: {{ $.Values.kubernetes.namespace }}
  use_output: {{ $.Values.kubernetes.output }}
  streams:
  - id: kubernetes/metrics-kubernetes.state_node
    data_stream:
      type: metrics
      dataset: kubernetes.state_node
    metricsets:
      - state_node
{{- $defaults := (include "elasticagent.kubernetes.config.state.nodes.default_vars" $ ) | fromYaml -}}
{{- mergeOverwrite $defaults .Values.kubernetes.nodes.state.vars | toYaml | nindent 4 }}
{{- end -}}

{{- define "elasticagent.kubernetes.config.state.nodes.default_vars" -}}
add_metadata: true
hosts:
{{- if eq $.Values.kubernetes.state.deployKSM true }}
  - 'localhost:8080'
{{- else }}
  - {{ $.Values.kubernetes.state.host }}
{{- end }}
period: 10s
{{- if eq $.Values.kubernetes.state.deployKSM false }}
condition: '${kubernetes_leaderelection.leader} == true'
{{- end }}
bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
{{- end -}}