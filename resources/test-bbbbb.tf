# cloudResource.tf

resource "aws_s3_bucket" "test-bbbbb" {
provider = aws.bucket_region
name = "test-bbbbb"
acl = "public"
}
