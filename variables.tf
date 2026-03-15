variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = null
}

variable "chart_version" {
  description = "Version of the bootstrap-argo chart to deploy"
  type        = string
}

variable "chart_repo" {
  description = "Helm repository hosting the chart"
  type        = string
}

variable "chart_name" {
  description = "Chart name within the repository"
  type        = string
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
  description = "Non-sensitive Helm values passed to the chart"
  type        = any
  default     = {}
}

variable "sensitive_values" {
  description = "Sensitive Helm values passed via set_sensitive (dot-notation keys)"
  type        = map(string)
  default     = {}
  sensitive   = true
}
