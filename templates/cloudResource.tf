# cloudResource.tf

resource "aws_s3_bucket" "{{ bucket_name }}" {
provider = aws.bucket_region
name = "{{ bucket_name }}"
acl = "{{ bucket_acl }}"
}
