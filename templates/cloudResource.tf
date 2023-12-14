# cloudResource.tf

variable "resource_prefix" {
  description = "Prefix for resource name"
  type        = string
}

variable "resource_suffix" {
  description = "Suffix for resource name"
  type        = string
}

variable "resource_count" {
  description = "Number of resources to create"
  type        = number
}

resource "aws_s3_bucket" "example" {
  provider = aws.bucket_region
  count    = var.resource_count

  name = "${var.resource_prefix}-example-${count.index + 1}-${var.resource_suffix}"
  acl  = "{{ bucket_acl }}"
}
