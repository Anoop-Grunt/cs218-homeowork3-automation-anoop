terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.region
}

# ----------------------------
# VPC
# ----------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.name}_vpc"
  })
}

# ----------------------------
# INTERNET GATEWAY
# ----------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}_igw"
  })
}

# ----------------------------
# PUBLIC SUBNET
# ----------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.public_subnet_az
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.name}_public_subnet"
  })
}

# ----------------------------
# PRIVATE SUBNET
# ----------------------------
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.private_subnet_az

  tags = merge(local.common_tags, {
    Name = "${var.name}_private_subnet"
  })
}

# ----------------------------
# ELASTIC IP for NAT Gateway
# ----------------------------
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.name}_nat_eip"
  })
}

# ----------------------------
# NAT GATEWAY
# ----------------------------
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw]

  tags = merge(local.common_tags, {
    Name = "${var.name}_nat_gateway"
  })
}

# ----------------------------
# PUBLIC ROUTE TABLE
# ----------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}_public_rt"
  })
}

# ----------------------------
# PRIVATE ROUTE TABLE
# ----------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}_private_rt"
  })
}

# ----------------------------
# ROUTE TABLE ASSOCIATIONS
# ----------------------------
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# ----------------------------
# SECURITY GROUPS
# ----------------------------
resource "aws_security_group" "public_sg" {
  name        = "${var.name}_public_sg"
  description = "Allow inbound SSH and HTTP for public instance"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}_public_sg"
  })
}

resource "aws_security_group" "private_sg" {
  name        = "${var.name}_private_sg"
  description = "Allow private instance access via NAT and public SG"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}_private_sg"
  })
}

# ----------------------------
# EC2 INSTANCES
# ----------------------------
resource "aws_instance" "public_instance" {
  ami                         = var.ami
  instance_type               = var.instance_type_public
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = "${var.name}_public_instance"
  })
}

resource "aws_instance" "private_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type_private
  subnet_id              = aws_subnet.private.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = merge(local.common_tags, {
    Name = "${var.name}_private_instance"
  })
}
