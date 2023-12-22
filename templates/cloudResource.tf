# cloudResource.tf

resource "aws_s3_bucket" "s3-bucket" {
name = "{{ bucket_name }}"
acl = "{{ bucket_acl }}"
}
