# cloudResource.tf

resource "aws_s3_bucket" "s3-bucket" {
provider = aws.bucket_region
name = "{{ bucket_name }}"
acl = "{{ bucket_acl }}"
}
