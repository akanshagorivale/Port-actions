# cloudResource.tf

resource "aws_s3_bucket" "s3-bucket" {
  bucket = "bucket-dec22"
}

resource "aws_lambda_function" "lambda-function" {
  architectures = ["x86_64"]
  description   = "An Amazon SQS trigger that logs messages in a queue."

  ephemeral_storage {
    size = "512"
  }

  function_name                  = "test-function-dec22"
  filename                       = "lambda_function.zip"
  handler                        = "index.handler"
  memory_size                    = "128"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = "arn:aws:iam::660969952193:role/okta-role"
  runtime                        = "nodejs16.x"

  timeout = "3"

  tracing_config {
    mode = "PassThrough"
  }

  vpc_config {
    subnet_ids         = ["subnet-0e0417ad12bcbd3c2"]
    security_group_ids = ["sg-08a5d93965cb14f50"]
  }

#  depends_on = [aws_iam_role.lambda-to-opensearch-role]
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "dynamodb-dec22"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserId"
  range_key      = "GameTitle"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "GameTitle"
    type = "S"
  }

  attribute {
    name = "TopScore"
    type = "N"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  global_secondary_index {
    name               = "GameTitleIndex"
    hash_key           = "GameTitle"
    range_key          = "TopScore"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["UserId"]
  }
}
