### EKS IAM cluster role 
resource "aws_iam_role" "eks_cluster_role" {
  name               = var.cluster_role
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = {
    Name = "${var.cluster_role}"
  }
}

### IAM policy for cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}
resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

### EKS cluster master node security group
resource "aws_security_group" "master_node_sg" {
  name        = "${var.cluster_name}_MN_sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.cluster_name}_MN_sg"
  }
}

### EKS cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_version
  vpc_config {
    subnet_ids         = aws_subnet.eks_pub_sub.*.id
    security_group_ids = [aws_security_group.master_node_sg.id]
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_policy,
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSServicePolicy,
  ]
}
