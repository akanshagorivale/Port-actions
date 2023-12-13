# cloudResource.tf

resource "aws_s3_bucket" "example" {
provider = aws.bucket_region
name = "sample-s3-bucket"
acl = "public"
}
