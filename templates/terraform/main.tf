# cloudResource.tf

resource "aws_vpc" "vpc_1" {

  cidr_block = var.vpc_cidr_block
  # enable_classiclink               = "false"
  # enable_classiclink_dns_support   = "false"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"
  instance_tenancy     = "default"

  tags = {
    Name    = "${var.environment}-vpc"
    
  }

  tags_all = {
    Name    = "${var.environment}-vpc"
    
  }
}

resource "aws_subnet" "public_sn1" {
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = var.public_subnet1_cidr_block
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.environment}-public-subnet"
  }
}

resource "aws_subnet" "private_sn1" {
  vpc_id            = aws_vpc.vpc_1.id
  cidr_block        = var.private_subnet1_cidr_block
  availability_zone = "ap-southeast-1a"
  tags = {
    Name    = "${var.environment}-private-subnet"

  }
}




resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.environment}-public-route-table"

  }
}



resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_1.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
 

  tags = {
    Name    = "${var.environment}-private-route-table"

  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name    = "${var.environment}-internet-gateway"

  }
}

resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "natgw" {
  subnet_id         = aws_subnet.public_sn1.id
  allocation_id     = aws_eip.eip.id
  private_ip        = var.nat_private_ip
  connectivity_type = "public"

  tags = {
    Name    = "${var.environment}-nat-gateway"

  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_sn1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private_sn1.id
  route_table_id = aws_route_table.private_rt.id
}




resource "aws_network_acl" "public1-nacl" {
  vpc_id = aws_vpc.vpc_1.id

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name    = "${var.environment}-public-subnet-nacl"

  }
}

resource "aws_network_acl" "private1-nacl" {
  vpc_id = aws_vpc.vpc_1.id

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name    = "${var.environment}-private-subnet-nacl"

  }
}




resource "aws_network_acl_association" "public1-nacl" {
  network_acl_id = aws_network_acl.public1-nacl.id
  subnet_id      = aws_subnet.public_sn1.id
}

resource "aws_network_acl_association" "private1-nacl" {
  network_acl_id = aws_network_acl.private1-nacl.id
  subnet_id      = aws_subnet.private_sn1.id
}



resource "aws_s3_bucket" "s3-bucket" {
  bucket = "${var.environment}-bucket"
}

resource "aws_security_group" "lambda_sg" {
  name        = "${var.environment}-security-group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc_1.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.environment}-security-group"
  }
}

resource "aws_iam_role" "lambda-function-role" {
  name = "${var.environment}-lambda-function-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      { Sid = "",
        "Effect" : "Allow",
        "Principal" : {

          "Service" : [
            
           "lambda.amazonaws.com"
          ]
       },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "policy" {
  name        = "${var.environment}-lambda-policy"
  description = "lambda-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "lambda:ListFunctions",
                "lambda:ListEventSourceMappings",
                "lambda:ListLayerVersions",
                "lambda:ListLayers",
                "lambda:GetAccountSettings",
                "lambda:CreateEventSourceMapping",
                "lambda:ListCodeSigningConfigs",
                "lambda:CreateCodeSigningConfig",
                "lambda:InvokeFunction"
            ],
            "Resource": "*"
        },
        {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances",
        "ec2:AttachNetworkInterface"
      ],
      "Resource": "*"
    }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "role_attach2" {
  role       = aws_iam_role.lambda-function-role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_lambda_function" "lambda-function" {
  architectures = ["x86_64"]
  description   = "An Amazon SQS trigger that logs messages in a queue."

  ephemeral_storage {
    size = "512"
  }

  function_name                  = "${var.environment}-lambda-function"
  filename                       = "lambda_function.zip"
  handler                        = "index.handler"
  memory_size                    = "128"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = aws_iam_role.lambda-function-role.arn
  runtime                        = "nodejs16.x"

  timeout = "3"

  tracing_config {
    mode = "PassThrough"
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private_sn1.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  depends_on = [aws_iam_role.lambda-function-role]
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "${var.environment}-dynamodb"
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
