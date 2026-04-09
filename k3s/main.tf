# =============================================================
#  HealthPulse Portal — k3s Kubernetes Cluster
#  1 master + 2 workers on EC2 instances
# =============================================================

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "HealthPulse"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Team        = var.team_name
      DeployType  = "k3s"
    }
  }
}

# ─────────────── RANDOM TOKEN ───────────────
# Shared secret used by workers to join the master
resource "random_password" "k3s_token" {
  length  = 32
  special = false
}

# ─────────────── DATA ───────────────
data "aws_availability_zones" "available" {
  state = "available"
}

# ─────────────── VPC ───────────────
resource "aws_vpc" "k3s" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-${var.environment}-k3s-vpc"
  }
}

resource "aws_internet_gateway" "k3s" {
  vpc_id = aws_vpc.k3s.id

  tags = {
    Name = "${var.project_name}-${var.environment}-k3s-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.k3s.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-k3s-public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.k3s.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k3s.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-k3s-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ─────────────── KEY PAIR ───────────────
resource "aws_key_pair" "k3s" {
  key_name   = "${var.project_name}-${var.environment}-k3s-key"
  public_key = var.ssh_public_key
}

# ─────────────── SECURITY GROUP ───────────────
resource "aws_security_group" "k3s" {
  name_prefix = "${var.project_name}-${var.environment}-k3s-"
  description = "k3s cluster security group"
  vpc_id      = aws_vpc.k3s.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  # HTTP (for app access)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API (kubectl access)
  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  # NodePort range (for services)
  ingress {
    description = "NodePort Services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all traffic within the cluster
  ingress {
    description = "Intra-cluster"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-k3s-sg"
  }
}

# ─────────────── MASTER NODE ───────────────
resource "aws_instance" "master" {
  ami                    = var.ami_id
  instance_type          = var.master_instance_type
  key_name               = aws_key_pair.k3s.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k3s.id]

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/scripts/master-deploy.sh", {
    k3s_token = random_password.k3s_token.result
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-k3s-master"
    Role = "master"
  }
}

# ─────────────── WORKER NODES ───────────────
resource "aws_instance" "worker" {
  count                  = var.worker_count
  ami                    = var.ami_id
  instance_type          = var.worker_instance_type
  key_name               = aws_key_pair.k3s.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k3s.id]

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/scripts/worker-deploy.sh", {
    k3s_token    = random_password.k3s_token.result
    master_ip    = aws_instance.master.private_ip
    worker_index = count.index + 1
  })

  depends_on = [aws_instance.master]

  tags = {
    Name = "${var.project_name}-${var.environment}-k3s-worker-${count.index + 1}"
    Role = "worker"
  }
}

# ─────────────── ELASTIC IP (Master only) ───────────────
resource "aws_eip" "master" {
  instance = aws_instance.master.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-k3s-master-eip"
  }
}
