output "apps_release" {
  value = {
    name   = helm_release.apps.name
    status = helm_release.apps.status
  }
}

output "secrets_release" {
  value = {
    name   = helm_release.secrets.name
    status = helm_release.secrets.status
  }
}
