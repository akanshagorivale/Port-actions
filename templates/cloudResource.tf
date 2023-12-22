# cloudResource.tf

resource "aws_vpc" "vpc_1" {

  cidr_block = "172.26.0.0/16"
  # enable_classiclink               = "false"
  # enable_classiclink_dns_support   = "false"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"
  instance_tenancy     = "default"

  tags = {
    Name    = "test-vpc-dec22"
    
  }

  tags_all = {
    Name    = "test-vpc-dec22"
    
  }
}

resource "aws_subnet" "public_sn1" {
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = "172.26.0.0/22"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "public-subnet-dec22"
  }
}

resource "aws_subnet" "private_sn1" {
  vpc_id            = aws_vpc.vpc_1.id
  cidr_block        = "172.26.4.0/22"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name    = "private-subnet-dec22"

  }
}




resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "public-route-table-dec22"

  }
}



resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_1.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "172.26.1.0"
  }
 

  tags = {
    Name    = "private-route-table-dec22"

  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name    = "igw-dec22"

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
    Name    = "nat-gw-dec22"

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
    Name    = "public-subnet-nacl-dec22"

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
    Name    = "private-subnet-nacl-dec22"

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
  bucket = "s3-bucket-dec22"
}

resource "aws_security_group" "lambda_sg" {
  name        = "security-group-dec22"
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
    Name    = "security-group-dec22"
  }
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
    subnet_ids         = [aws_subnet.private_sn1.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
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
