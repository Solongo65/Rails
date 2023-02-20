### VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block                     = var.cidr_block
  enable_dns_hostnames           = true
  enable_classiclink_dns_support = false
  tags = {
    Name                                        = "${var.vpc_name}vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

### Public subnets
data "aws_availability_zones" "available" {}
resource "aws_subnet" "eks_pub_sub" {
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = "true"
  tags = {
    Name                                        = "${var.vpc_name}pub_sub_${count.index +1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

### Internet gateway
resource "aws_internet_gateway" "eks_ig" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "${var.vpc_name}ig"
  }
}

### Public subnets route table
resource "aws_route_table" "eks_public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_ig.id
  }
  tags = {
    Name = "${var.vpc_name}pub_sub_rt"
  }
}

### Public subnets route table association
resource "aws_route_table_association" "eks_pub_sub_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.eks_pub_sub.*.id[count.index]
  route_table_id = aws_route_table.eks_public_route_table.id
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_subnet.eks_pub_sub,
    aws_route_table.eks_public_route_table,
  ]
}