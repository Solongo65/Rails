### Provider AWS
variable "region" {
  type        = string
  description = "region for provider AWS"
}

### VPC
variable "cidr_block" {
  type        = string
  description = "vpc cidr block"
}

variable "vpc_name" {
  type        = string
  description = "name of vpc"
}

variable "public_subnets" {
  type        = list(any)
  description = "List of public subnets"

}

### EKS cluster role 
variable "cluster_name" {
  type        = string
  description = "name of eks cluster"
}

variable "cluster_role" {
  type        = string
  description = "name of eks iam cluster role"
}

variable "eks_version" {
  type        = number
  description = "version of eks cluster"
}

### EKS worker node group
variable "eks_wn_role" {
  type        = string
  description = "name of the eks worker node role"
}

variable "instance_type" {
  type        = string
  description = "eks cluster default instance type"
}

variable "desired_capacity" {
  type        = number
  description = "EKS cluster desired number of worker nodes"
}

variable "max_size" {
  type        = number
  description = "EKS cluster max number of worker nodes"
}

variable "min_size" {
  type        = number
  description = "EKS cluster min number of worker nodes"
}

variable "spot_allocation_strategy" {
  type        = string
  description = "EKS cluster allocation strategy for spot instances"
}

variable "instance_types" {
  type        = list
  description = "instance types for worker nodes"
}
