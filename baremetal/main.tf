# =============================================================
#  HealthPulse Portal — Bare-Metal EC2 Instance
#  Creates VPC, Subnet, and EC2 with Nginx pre-installed
# =============================================================

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  access_key = "AKIARSFWRGUYF6xxxxxxxxxxxxxxxxxxxxxxxxx"
  secret_key = "lmAqWC8vZUhq5xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  default_tags {
    tags = {
      Project     = "HealthPulse"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Team        = var.team_name
      DeployType  = "baremetal"
    }
  }
}

# ─────────────── DATA ───────────────
data "aws_availability_zones" "available" {
  state = "available"
}

# ─────────────── VPC ───────────────
resource "aws_vpc" "baremetal" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-${var.environment}-baremetal-vpc"
  }
}

# ─────────────── INTERNET GATEWAY ───────────────
resource "aws_internet_gateway" "baremetal" {
  vpc_id = aws_vpc.baremetal.id

  tags = {
    Name = "${var.project_name}-${var.environment}-baremetal-igw"
  }
}

# ─────────────── PUBLIC SUBNET ───────────────
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.baremetal.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-baremetal-public"
  }
}

# ─────────────── ROUTE TABLE ───────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.baremetal.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.baremetal.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-baremetal-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ─────────────── KEY PAIR ───────────────
resource "aws_key_pair" "deployer" {
  key_name   = "Genkey"
  public_key = var.ssh_public_key
}

# ─────────────── SECURITY GROUP ───────────────
resource "aws_security_group" "web" {
  name_prefix = "${var.project_name}-${var.environment}-web-"
  description = "Allow HTTP, HTTPS, and SSH"
  vpc_id      = aws_vpc.baremetal.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
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
    Name = "${var.project_name}-${var.environment}-web-sg"
  }
}

# ─────────────── EC2 INSTANCE ───────────────
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  # Bootstrap: install Nginx and create deployment directory
  user_data = file("deploy.sh")
    

  tags = {
    Name = "${var.project_name}-${var.environment}-web"
  }
}

# ─────────────── ELASTIC IP ───────────────
resource "aws_eip" "web" {
  instance = aws_instance.web.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-eip"
  }
}
