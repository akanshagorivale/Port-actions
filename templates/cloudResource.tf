# cloudResource.tf

provider "aws" {
  region = "ap-southeast-1"
  # Other configuration options...
}


resource "aws_s3_bucket" "example" {
provider = aws.bucket_region
name = "{{ bucket_name }}"
acl = "{{ bucket_acl }}"
}
