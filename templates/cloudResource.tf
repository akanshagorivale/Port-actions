# cloudResource.tf

provider "aws" {
  region = "ap-southeast-1"  # Replace with your desired AWS region
}

resource "aws_s3_bucket" "example23" {
provider = aws.bucket_region
name = "{{ bucket_name }}"
acl = "{{ bucket_acl }}"
}
