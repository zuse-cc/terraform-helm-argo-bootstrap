mock_provider "linode" {}

mock_provider "random" {
  mock_resource "random_string" {
    defaults = {
      result = "abcd"
    }
  }
}

variables {
  stage   = "tst"
  service = "bucket"
  region  = "eu-central"
}

run "sets_correct_name_and_region" {
  assert {
    condition     = linode_object_storage_bucket.b.label == "${var.stage}-${var.service}-abcd"
    error_message = "incorrect bucket name"
  }

  assert {
    condition     = linode_object_storage_bucket.b.region == var.region
    error_message = "incorrect bucket region"
  }
}

run "sets_private_acl" {
  assert {
    condition     = linode_object_storage_bucket.b.acl == "private"
    error_message = "bucket ACL is not set to private"
  }
}
