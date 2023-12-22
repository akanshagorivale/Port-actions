# cloudResource.tf

resource "aws_s3_bucket" "s3-bucket" {
  bucket = "{{ bucket_name }}"
  acl = "{{ bucket_acl }}"
}
