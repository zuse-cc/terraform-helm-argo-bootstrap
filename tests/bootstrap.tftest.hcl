mock_provider "helm" {}
mock_provider "github" {}
mock_provider "tls" {}

variables {
  stack_name = "my-stack"

  apps = {
    chart_repo = "oci://ghcr.io/example/helm"
  }

  source_repo = {
    repo_name       = "my-gitops-repo"
    repo_url        = "https://github.com/example/gitops"
    target_revision = "main"
  }

  registry = {
    username = "user"
    password = "pass"
  }
}

run "release_name_defaults_to_chart_name" {
  assert {
    condition     = helm_release.apps.name == var.apps.chart_name
    error_message = "release name should default to chart_name when release_name is not set"
  }
}

run "release_name_uses_provided_value" {
  variables {
    apps = {
      release_name = "custom-release"
      chart_repo   = "oci://ghcr.io/example/helm"
    }
  }

  assert {
    condition     = helm_release.apps.name == "custom-release"
    error_message = "release name should use the provided release_name variable"
  }
}

run "helm_release_uses_correct_chart_and_version" {
  assert {
    condition     = helm_release.apps.chart == var.apps.chart_name
    error_message = "helm release chart does not match chart_name"
  }

  assert {
    condition     = helm_release.apps.version == var.apps.chart_version
    error_message = "helm release version does not match chart_version"
  }

  assert {
    condition     = helm_release.apps.repository == var.apps.chart_repo
    error_message = "helm release repository does not match chart_repo"
  }
}

run "namespace_defaults_to_argocd" {
  assert {
    condition     = helm_release.apps.namespace == "argocd"
    error_message = "namespace should default to argocd"
  }
}

run "namespace_uses_provided_value" {
  variables {
    namespace = "custom-ns"
  }

  assert {
    condition     = helm_release.apps.namespace == "custom-ns"
    error_message = "namespace should use the provided value"
  }
}

run "secrets_uses_kubernetes_backend_by_default" {
  assert {
    condition     = helm_release.secrets.namespace == "${var.stack_name}-secrets"
    error_message = "secrets should deploy to stack-secrets namespace when infisical is not set"
  }
}

run "secrets_uses_infisical_backend_when_configured" {
  variables {
    infisical = {
      auth = {
        client_id     = "test-id"
        client_secret = "test-secret"
      }
      project_slug = "my-project"
      environment  = "dev"
      path         = "/secrets"
    }
  }

  assert {
    condition     = helm_release.secrets.namespace == "external-secrets"
    error_message = "secrets should deploy to external-secrets namespace when infisical is configured"
  }
}
