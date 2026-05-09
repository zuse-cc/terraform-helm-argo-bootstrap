variable "stack_name" {
  description = "Stack name — used as ArgoCD project name, Application prefix, ClusterSecretStore name, and local-secrets namespace prefix"
  type        = string
}

variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = null
}

variable "apps" {
  description = "Settings for the applications helm chart. Only chart_repo is required — name and version default to the charts bundled with this module."
  type = object({
    release_name  = optional(string, null)
    chart_name    = optional(string, "argo-appstack")
    chart_version = optional(string, "0.1.0")
    chart_repo    = string
  })
}

variable "secrets" {
  description = "Settings for the secrets helm chart. Defaults to the chart bundled with this module at the same version as apps."
  type = object({
    release_name  = optional(string, null)
    chart_name    = optional(string, "argo-appstack-secrets")
    chart_version = optional(string, null)
    chart_repo    = optional(string, null)
  })
  default = {}
}

variable "source_repo" {
  type = object({
    repo_name       = string
    repo_url        = string,
    target_revision = optional(string, "HEAD")
  })
}

variable "registry" {
  description = "Registry credentials to pull charts and images from private repos"
  type = object({
    username = string
    password = string
  })
}

variable "namespace" {
  description = "Namespace to deploy into (must match the ArgoCD namespace)"
  type        = string
  default     = "argocd"
}

variable "values" {
  description = "Non-sensitive Helm values passed to the chart. Do NOT use for secrets!"
  type        = any
  default     = {}
}

variable "sensitive_values" {
  description = "Sensitive Helm values passed via set_sensitive (dot-notation keys)"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "infisical" {
  description = "Infisical configuration for the secrets backend. When set, the Infisical ClusterSecretStore is used; omit to use the local Kubernetes secrets backend."
  type = object({
    auth = object({
      client_id     = string
      client_secret = string
    })
    project_slug = string
    environment  = string
    path         = string
    endpoint     = optional(string, "https://eu.infisical.com")
  })
  default = null
}
