variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = null
}

variable "apps" {
  description = "Settings for the applications helm chart."
  type = object({
    release_name  = optional(string, null)
    chart_version = string
    chart_repo    = string
    chart_name    = string
  })
}

variable "secrets" {
  description = "Settings for the secrets helm chart. Uses chart_version and chart_repo from apps if not set here"
  type = object({
    release_name  = optional(string, null)
    chart_version = optional(string, null)
    chart_repo    = optional(string, null)
    chart_name    = string
  })
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
  description = "We use Infisical to pass secrets to the cluster, use this to configure it"
  type = object({
    auth = object({
      client_id     = string
      client_secret = string
    })
    # project_id = optional(string) # Required when authelia.enabled = true
    project_slug = string
    environment  = string
    path         = string
    endpoint     = optional(string, "https://eu.infisical.com")
  })
}
