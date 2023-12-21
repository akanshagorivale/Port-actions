# cloudResource.tf

resource "aws_s3_bucket" "testttttt" {
provider = aws.bucket_region
name = "testttttt"
acl = "public"
}
