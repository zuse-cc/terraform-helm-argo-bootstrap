locals {
  secrets_namespace = var.infisical != null ? "external-secrets" : "${var.stack_name}-secrets"

  sensitive_values = {
    "source.username" = var.registry.username,
    "source.password" = var.registry.password
  }

  custom_values = merge(
    {
      "stack.name"                           = var.stack_name
      "source.targetRevision"                = var.source_repo.target_revision
      "source.repoURL"                       = var.source_repo.repo_url
      "helm.repoURL"                         = var.apps.chart_repo
      "secrets.backend.kubernetes.namespace" = local.secrets_namespace
    },
    var.infisical != null ? {
      "secrets.backend.infisical.endpoint"    = var.infisical.endpoint
      "secrets.backend.infisical.environment" = var.infisical.environment
      "secrets.backend.infisical.projectSlug" = var.infisical.project_slug
      "secrets.backend.infisical.secretsPath" = var.infisical.path
    } : {}
  )

  infisical_auth_values = var.infisical != null ? {
    "universalAuth.clientId"     = var.infisical.auth.client_id
    "universalAuth.clientSecret" = var.infisical.auth.client_secret
  } : {}
}

# Do NOT pass anything sensitive into this chart — values are passed
# directly into ArgoCD via helm and may be exposed in the GUI.
resource "helm_release" "apps" {
  name       = coalesce(var.apps.release_name, var.apps.chart_name)
  chart      = var.apps.chart_name
  version    = var.apps.chart_version
  repository = var.apps.chart_repo
  namespace  = var.namespace
  values     = [yamlencode(var.values)]

  set = [for k, v in local.custom_values : {
    name  = k
    value = v
  }]

  set_sensitive = [for k, v in local.sensitive_values : {
    name  = k
    value = v
  }]
}

# Provides ESO with credentials to access the secrets backend.
# For the Infisical backend: creates the universal-auth-credentials secret.
# For the Kubernetes backend: seeds app secrets into the local-secrets namespace.
resource "helm_release" "secrets" {
  name       = coalesce(var.secrets.release_name, var.secrets.chart_name)
  chart      = var.secrets.chart_name
  version    = coalesce(var.secrets.chart_version, var.apps.chart_version)
  repository = coalesce(var.secrets.chart_repo, var.apps.chart_repo)
  namespace  = local.secrets_namespace

  set = var.infisical != null ? [
    {
      name  = "backend"
      value = "infisical"
    },
    {
      name  = "secret.name"
      value = "${var.stack_name}-credentials"
    }
  ] : []

  set_sensitive = [for k, v in local.infisical_auth_values : {
    name  = k
    value = v
  }]
}
