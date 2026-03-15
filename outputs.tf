output "bucket" {
  value = linode_object_storage_bucket.b.label
}

output "endpoint" {
  value = linode_object_storage_bucket.b.s3_endpoint
}
