provider "aws" {
  region = "ap-southeast-1"  # Change this to your desired AWS region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

resource "aws_dynamodb_table" "my_table" {
  name           = "MyTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "N"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-s3-bucket-name"
  acl    = "private"
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "MyLambdaFunction"
  runtime       = "nodejs14.x"
  handler       = "index.handler"
  filename      = "lambda_function.zip"
  source_code_hash = filebase64("lambda_function.zip")

  role = aws_iam_role.lambda.arn

  depends_on = [aws_iam_role.lambda]
}

resource "aws_iam_role" "lambda" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda" {
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
  role       = aws_iam_role.lambda.name
}

