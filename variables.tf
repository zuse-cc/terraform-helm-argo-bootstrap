variable "region" {
  description = "Linode region to create the bucket in"
  type        = string
}

variable "stage" {
  description = "Deployment stage"
  type        = string
}

variable "service" {
  description = "Service name"
  type        = string
}

variable "versioning" {
  description = "Enable versioning for the bucket"
  type = object({
    enabled           = bool
    access_key_id     = optional(string)
    secret_access_key = optional(string)
  })
  default = {
    enabled = false
  }
}
