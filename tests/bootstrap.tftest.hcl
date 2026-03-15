mock_provider "helm" {}
mock_provider "github" {}
mock_provider "tls" {}

variables {
  chart_name    = "bootstrap-argo"
  chart_version = "1.0.0"
  chart_repo    = "https://charts.example.com"

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
    condition     = helm_release.bootstrap.name == var.chart_name
    error_message = "release name should default to chart_name when release_name is not set"
  }
}

run "release_name_uses_provided_value" {
  variables {
    release_name = "custom-release"
  }

  assert {
    condition     = helm_release.bootstrap.name == "custom-release"
    error_message = "release name should use the provided release_name variable"
  }
}

run "helm_release_uses_correct_chart_and_version" {
  assert {
    condition     = helm_release.bootstrap.chart == var.chart_name
    error_message = "helm release chart does not match chart_name"
  }

  assert {
    condition     = helm_release.bootstrap.version == var.chart_version
    error_message = "helm release version does not match chart_version"
  }

  assert {
    condition     = helm_release.bootstrap.repository == var.chart_repo
    error_message = "helm release repository does not match chart_repo"
  }
}

run "namespace_defaults_to_argocd" {
  assert {
    condition     = helm_release.bootstrap.namespace == "argocd"
    error_message = "namespace should default to argocd"
  }
}

run "namespace_uses_provided_value" {
  variables {
    namespace = "custom-ns"
  }

  assert {
    condition     = helm_release.bootstrap.namespace == "custom-ns"
    error_message = "namespace should use the provided value"
  }
}
