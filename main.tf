data "infisical_projects" "p" {
  count = var.infisical != null ? 1 : 0
  slug  = var.infisical.project_slug
}

resource "infisical_secret_folder" "cluster" {
  count            = var.infisical != null ? 1 : 0
  environment_slug = var.infisical.environment
  folder_path      = var.infisical.parent_path
  name             = var.infisical.cluster_name
  project_id       = data.infisical_projects.p[0].id
}

resource "infisical_secret_folder" "stack" {
  count            = var.infisical != null ? 1 : 0
  environment_slug = var.infisical.environment
  folder_path      = infisical_secret_folder.cluster[0].path
  name             = var.stack_name
  project_id       = data.infisical_projects.p[0].id
}

# count rather than for_each: the secrets map is sensitive (values derived from
# random_password), and Terraform propagates that taint to the entire var.infisical
# object, making keys() sensitive too. length() is exempt from sensitivity
# propagation, so count unblocks iteration. Reordering the map causes
# destroy/recreate cycles, but ESO maintains the last synced value during any gap.
resource "infisical_secret" "secrets" {
  count = var.infisical != null ? length(var.infisical.secrets) : 0

  name         = keys(var.infisical.secrets)[count.index]
  value        = values(var.infisical.secrets)[count.index]
  env_slug     = var.infisical.environment
  workspace_id = data.infisical_projects.p[0].id
  folder_path  = infisical_secret_folder.stack[0].path
}

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
      "helm.repoURL"                         = trimprefix(var.apps.chart_repo, "oci://")
      "secrets.backend.kubernetes.namespace" = local.secrets_namespace
    },
    var.infisical != null ? {
      "secrets.backend.infisical.endpoint"    = var.infisical.endpoint
      "secrets.backend.infisical.environment" = var.infisical.environment
      "secrets.backend.infisical.projectSlug" = var.infisical.project_slug
      "secrets.backend.infisical.secretsPath" = infisical_secret_folder.stack[0].path
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
  name       = coalesce(var.apps.release_name, "${var.stack_name}-apps")
  chart      = var.apps.chart_name
  version    = var.apps.chart_version
  repository = var.apps.chart_repo
  namespace  = var.namespace
  values     = [yamlencode(var.values)]

  set = concat(
    [for k, v in local.custom_values : {
      name  = k
      value = v
    }],
    [for i, v in var.extra_source_repos : {
      name  = "extraSourceRepos[${i}]"
      value = v
    }]
  )

  set_sensitive = [for k, v in local.sensitive_values : {
    name  = k
    value = v
  }]
}

# Provides ESO with credentials to access the secrets backend.
# For the Infisical backend: creates the universal-auth-credentials secret.
# For the Kubernetes backend: seeds app secrets into the local-secrets namespace.
resource "helm_release" "secrets" {
  name       = coalesce(var.secrets.release_name, "${var.stack_name}-secrets")
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
