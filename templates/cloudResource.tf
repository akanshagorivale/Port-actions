# cloudResource.tf

resource "aws_s3_bucket" "s3-bucket" {
provider = "ap-southeast-1"
name = "{{ bucket_name }}"
acl = "{{ bucket_acl }}"
}
