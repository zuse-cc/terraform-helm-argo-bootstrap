locals {
  release_name = var.release_name != null ? var.release_name : var.chart_name

  # principle of least surprise - user provided values take precedence
  sensitive_values = merge(
    {
      "source.targetRevision" = var.source_repo.target_revision,
      "source.repoURL"        = var.source_repo.repo_url,
      "source.username"       = var.registry.username,
      "source.password"       = var.registry.password
      "helm.repoURL"          = var.chart_repo,
    },
    var.sensitive_values
  )
}

resource "helm_release" "bootstrap" {
  name       = local.release_name
  repository = var.chart_repo
  chart      = var.chart_name
  version    = var.chart_version
  namespace  = var.namespace

  values = [yamlencode(var.values)]

  set_sensitive = concat([
    for k, v in merge(local.sensitive_values) :
    {
      name  = k
      value = v
    }
  ])
}
