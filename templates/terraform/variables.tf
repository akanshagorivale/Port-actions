variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
}

variable "public_subnet1_cidr_block" {
  description = "CIDR block for public subnet"
}

variable "private_subnet1_cidr_block" {
  description = "CIDR block for documentDB private subnet1"
}

variable "nat_private_ip" {
  description = "Private IP for NAT gateway"
}

variable "environment" {
  description = "Enviroment name"
}

variable "github_token" {
  description = "Github token"
}
