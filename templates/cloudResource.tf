# cloudResource.tf

resource "aws_s3_bucket" "s3-bucket" {
name = "testbucketttt"
acl = "public"
}
