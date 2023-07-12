{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}


{{- define "xap-manager.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "manager.replicas" -}}
{{- default .Values.ha | ternary 3 1 -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "xap-manager.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 55 | trimSuffix "-" -}}
{{- else -}}
{{- $name := .Values.name | default .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 55 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s" $name | trunc 55 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "xap-manager.dns-suffix" -}}
{{- $fullname := include "xap-manager.fullname" . -}}
{{- printf "%s-hs.%s.svc.cluster.local" $fullname .Release.Namespace  -}}
{{- end -}}

{{- define "xap-manager.servers" -}}
{{- $replicas := include "manager.replicas" . | int -}}
{{- $fullname := include "xap-manager.fullname" . -}}
{{- $dnssuffix := include "xap-manager.dns-suffix" . -}}
{{- $managers := list -}}
{{- range $i := until $replicas -}}
{{- $managers = printf "%s-%s.%s" $fullname ($i | toString) $dnssuffix | append $managers -}}
{{- end -}}
{{- join "," $managers -}}
{{- end -}}

{{- define "xap-manager.gs_lrmi_port" -}}
{{- $lrmiPort := .Values.service.lrmi.port |int  -}}
{{- $lrmiPortRange := $lrmiPort |add1 -}}
{{- printf "%s-%s" ($lrmiPort |toString) ($lrmiPortRange |toString) -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "xap-manager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "manager.baseopts" -}}
{{- printf "-Dcom.gs.multicast.enabled=%s %s" (.Values.multiCast.enabled |toString) (.Values.java.options | default "") -}}
{{- end -}}

