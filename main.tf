locals {
  label = "${var.stage}-${var.service}-${random_string.s.result}"
  tags  = ["stage:${var.stage}", "service:${var.service}", "component:backups"]
}

resource "random_string" "s" {
  length  = 4
  special = false
  upper   = false
}

resource "linode_object_storage_bucket" "b" {
  region = var.region
  label  = local.label

  access_key = var.versioning.enabled ? var.versioning.access_key_id : null
  secret_key = var.versioning.enabled ? var.versioning.secret_access_key : null

  versioning = var.versioning.enabled
  acl        = "private"
}
