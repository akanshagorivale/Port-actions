# cloudResource.tf

resource "aws_s3_bucket" "s3-bucket" {
  bucket = "bucket-dec22"
  acl = "public"
}
