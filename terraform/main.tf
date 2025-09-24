terraform {
  required_version = ">= 1.3"

  backend "s3" {} 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1" 
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  
  azs            = ["ap-south-1a", "ap-south-1b"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway      = false
  single_nat_gateway      = false
  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/cluster/tc-eks-cluster-tf" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"                  = "1"
    "kubernetes.io/cluster/tc-eks-cluster-tf" = "shared"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = "tc-eks-cluster-tf"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  cluster_enabled_log_types   = []
  create_cloudwatch_log_group = false

  cluster_endpoint_public_access       = true  
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  create_kms_key           = false
  cluster_encryption_config = {}

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.small"]
      desired_size   = 2
      min_size       = 2
      max_size       = 3

      iam_role_additional_policies = {
        worker = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        cni    = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        ecr    = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }
    }
  }
}


output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "region" {
  value = "ap-south-1"
}
