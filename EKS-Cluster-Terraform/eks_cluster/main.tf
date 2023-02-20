provider "aws" {
  region                   = var.region
}

### Backend
terraform {
    backend "s3" {}
 }

# terraform {
#   backend "s3" {
#     bucket                 = "eks-cluster-bucket-06012021"
#     key                    = "dynamodb_terraform_state_lock"
#     region                 = "us-east-1"
#     dynamodb_table         = "dynamodb_terraform_state_lock"
#   }
# }

module "eks_cluster" {

  ### VPC
  source                   = "./modules"
  cidr_block               = var.cidr_block 
  vpc_name                 = var.vpc_name 
  public_subnets           = var.public_subnets

  ### EKS Cluster
  cluster_name             = var.cluster_name 
  cluster_role             = var.cluster_role 
  eks_version              = var.eks_version 

  ### EKS worker node group
  eks_wn_role              = var.eks_wn_role 
  instance_type            = var.instance_type 
  desired_capacity         = var.desired_capacity 
  max_size                 = var.max_size 
  min_size                 = var.min_size 
  spot_allocation_strategy = var.spot_allocation_strategy 
  instance_types           = var.instance_types
}