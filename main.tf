locals {
  release_name = var.release_name != null ? var.release_name : var.chart_name

  # principle of least surprise - user provided values take precedence
  sensitive_values = {
    "source.username" = var.registry.username,
    "source.password" = var.registry.password
  }

  custom_values = {
    "source.targetRevision" = var.source_repo.target_revision,
    "source.repoURL"        = var.source_repo.repo_url,
    "helm.repoURL"          = var.chart_repo,
    "infisical.endpoint"    = var.infisical.endpoint,
    "infisical.environment" = var.infisical.environment,
    "infisical.projectSlug" = var.infisical.project_slug,
    "infisical.secretsPath" = var.infisical.path
  }

  infisical_auth_values = {
    "infisical.universalAuth.clientId"     = var.infisical.auth.client_id
    "infisical.universalAuth.clientSecret" = var.infisical.auth.client_secret
  }
}

# Do NOT pass anything sensitive into this chart, values will be passed 
# directly into ArgoCD via helm, so they may be exposed in the GUI!
resource "helm_release" "apps" {
  name       = "cloudlab-apps"
  chart      = "cloudlab-apps"
  version    = "0.1.0-625df5bf"
  repository = var.chart_repo
  namespace  = var.namespace
  values     = [yamlencode(var.values)]

  set = [for k, v in local.custom_values : {
    name  = k,
    value = v
  }]

  set_sensitive = [for k, v in local.sensitive_values : {
    name  = k,
    value = v
  }]
}

# All secrets MUST be stored in infisical and retrieved via ESO
# This chart only provides the initial secret for ESO to access Infisical
resource "helm_release" "secrets" {
  name       = "cloudlab-secrets"
  chart      = "cloudlab-secrets"
  version    = "0.1.0-625df5bf"
  repository = var.chart_repo
  namespace  = var.namespace

  set_sensitive = [for k, v in local.infisical_auth_values : {
    name  = k,
    value = v
  }]
}
