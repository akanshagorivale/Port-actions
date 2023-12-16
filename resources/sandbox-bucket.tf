# cloudResource.tf

resource "aws_s3_bucket" "sandbox-bucket" {
provider = aws.bucket_region
name = "sandbox-bucket"
acl = "private"
}
