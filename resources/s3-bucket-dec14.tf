# cloudResource.tf

provider "aws" {
  region = "ap-southeast-1"  # Replace with your desired AWS region
}

resource "aws_s3_bucket" "example" {
provider = aws.bucket_region
name = "s3-bucket-dec14"
acl = "private"
}
