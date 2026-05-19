locals {
  current_workspace = terraform.workspace
}

# Data sources để fix lỗi count argument trong EKS module
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

module "vpc" {
  source           = "./_modules/vpc"
  vpc_name         = var.vpc_name
  cidr_block       = var.vpc_cidr_block
  eks_cluster_name = var.eks_name
}

module "ec2instance" {
  depends_on      = [module.vpc]
  source          = "./_modules/ec2"
  for_each        = var.ec2instances                      // map of ec2 instances
  ec2key_name     = "${each.value.ec2InstanceName}-vmkey" // using item from map
  ec2InstanceName = each.value.ec2InstanceName
  ec2ami          = each.value.ec2ami
  ec2InstanceType = each.value.ec2InstanceType
  # If assiate_public_ip_address is false, use private subnet, otherwise use public subnet
  vpc_subnet_id             = each.value.assiate_public_ip_address ? coalesce(module.vpc.public_subnet_ids)[0] : coalesce(module.vpc.private_subnet_ids)[0]
  vpc_id                    = module.vpc.vpc_id
  trusted_ip_ranges         = each.value.trusted_ip_ranges
  default_tags              = var.default_tags
  ec2key_public_key         = each.value.public_key
  assiate_public_ip_address = each.value.assiate_public_ip_address
  ingress_rules             = lookup(each.value, "ingress_rules", null)
  user_data                 = lookup(each.value, "user_data", null)
  tags                      = var.default_tags
  my_aws_console_key        = var.my_aws_console_key
}

# ================== Security Groups for EKS Nodes and RDS ==================

# Security Group cho EKS Worker Nodes - CỐ ĐỊNH, không thay đổi khi nodes recreate
resource "aws_security_group" "eks_nodes_sg" {
  name_prefix = "${var.eks_name}-nodes-sg-"
  description = "Security group for EKS worker nodes - allows RDS connection"
  vpc_id      = module.vpc.vpc_id

  # Allow nodes to communicate with each other
  ingress {
    description = "Allow nodes to communicate with each other"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.eks_name}-nodes-sg"
    Environment = local.current_workspace
    Terraform   = "true"
    Purpose     = "EKS worker nodes"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group cho RDS - CHO PHÉP traffic từ EKS nodes
resource "aws_security_group" "rds_sg" {
  name_prefix = "${var.eks_name}-rds-sg-"
  description = "Security group for RDS - allows connection from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  # Allow MySQL/Aurora connection from EKS nodes
  ingress {
    description     = "MySQL/Aurora from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes_sg.id]
  }

  # Allow PostgreSQL connection from EKS nodes (nếu dùng PostgreSQL)
  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes_sg.id]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.eks_name}-rds-sg"
    Environment = local.current_workspace
    Terraform   = "true"
    Purpose     = "RDS database"
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = "21.15.1"  # Version mới nhất trong 21.x

  name               = var.eks_name
  kubernetes_version = "1.33"

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }

  # Optional
  endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  # Enable OIDC Provider for IAM roles for service accounts
  enable_irsa = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnet_ids
  control_plane_subnet_ids = module.vpc.private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    general_purpose = {
      # Fix lỗi "Invalid count argument" - set create = true explicitly
      create = true
      
      name = var.node_group_name
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]

      min_size     = 3  # Tăng min_size lên 2 để đảm bảo luôn có ít nhất 2 nodes
      max_size     = 4  # Tăng max_size để có khả năng scale tốt hơn
      desired_size = 3  # Duy trì 2 nodes cho HA

      # Chỉ định subnet_ids để đảm bảo nodes được phân bổ trên nhiều AZs
      subnet_ids = module.vpc.private_subnet_ids

      # QUAN TRỌNG: Gắn Security Group CỐ ĐỊNH vào nodes
      # BƯỚC 1: Comment dòng này để tránh recreate nodes và ảnh hưởng apps
      # Sau khi apply xong, uncomment và apply lại
      vpc_security_group_ids = [aws_security_group.eks_nodes_sg.id]

      # Pass partition và account_id từ data sources
      partition  = data.aws_partition.current.partition
      account_id = data.aws_caller_identity.current.account_id

      # Labels để phân loại nodes
      labels = {
        Environment = local.current_workspace
        NodeGroup   = "general-purpose"
      }

      # Tags để dễ quản lý
      tags = {
        Name        = "${var.node_group_name}-node"
        Environment = local.current_workspace
      }
    }
  }

  tags = {
    Environment = local.current_workspace
    Terraform   = "true"
  }
}

# ================== AWS Load Balancer Controller Setup ==================

# Download IAM policy document for AWS Load Balancer Controller
data "http" "alb_controller_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json"

  request_headers = {
    Accept = "application/json"
  }
}

# Create IAM policy for AWS Load Balancer Controller
resource "aws_iam_policy" "alb_controller" {
  name        = "${var.eks_name}-alb-controller-policy"
  path        = "/"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = data.http.alb_controller_iam_policy.response_body

  tags = {
    Environment = local.current_workspace
    Terraform   = "true"
  }
}

# Create IAM role for AWS Load Balancer Controller
resource "aws_iam_role" "alb_controller" {
  name = "${var.eks_name}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Environment = local.current_workspace
    Terraform   = "true"
  }
}

# Attach IAM policy to IAM role
resource "aws_iam_role_policy_attachment" "alb_controller" {
  policy_arn = aws_iam_policy.alb_controller.arn
  role       = aws_iam_role.alb_controller.name
}