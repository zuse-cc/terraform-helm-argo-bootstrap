output "release_name" {
  value = helm_release.bootstrap.name
}

output "release_status" {
  value = helm_release.bootstrap.status
}
