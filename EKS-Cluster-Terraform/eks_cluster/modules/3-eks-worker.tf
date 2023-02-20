### Worker node group IAM role 
resource "aws_iam_role" "eks_wn_role" {
  name               = var.eks_wn_role
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "eks_ebs_policy" {
  name = "Amazon_EBS_CSI_Driver"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteSnapshot",
        "ec2:DeleteTags",
        "ec2:DeleteVolume",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

### Worker node group role policy attachment
resource "aws_iam_role_policy_attachment" "eks_worker_node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_wn_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_wn_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_wn_role.name
}

### Worker node group instance profile
resource "aws_iam_instance_profile" "worker_nodes" {
  name = "${var.cluster_name}_worker_nodes"
  role = aws_iam_role.eks_wn_role.name
}

### Worker Node Group Security Groups 
resource "aws_security_group" "eks_worker" {
  name        = "${var.cluster_name}-worker_nodes"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.eks_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name                                        = "${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "ingress-self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.eks_worker.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress-cluster-https" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.master_node_sg.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress-cluster-others" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.master_node_sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-cluster-ingreass-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.master_node_sg.id
  source_security_group_id = aws_security_group.eks_worker.id
  to_port                  = 443
  type                     = "ingress"
}

### AMI for worker nodes
data "aws_ami" "eks_worker_ami" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_version}-v*"]
  }
  most_recent = true
  owners      = ["amazon"]
}

### Bootstrap user data for worker nodes
locals {
  node_userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks_cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks_cluster.certificate_authority.0.data}' '${var.cluster_name}'
USERDATA
}

### Launch Template for worker nodes
resource "aws_launch_template" "eks_worker_nodes" {
  iam_instance_profile {
    name = aws_iam_instance_profile.worker_nodes.name
  }
  image_id               = data.aws_ami.eks_worker_ami.id
  instance_type          = var.instance_type
  name_prefix            = var.cluster_name
  vpc_security_group_ids = [aws_security_group.eks_worker.id]
  user_data              = base64encode(local.node_userdata)
  lifecycle {
    create_before_destroy = true
  }
}

### AutoScaling group for worker nodes
resource "aws_autoscaling_group" "eks_worker_nodes_" {
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  name                = var.cluster_name
  vpc_zone_identifier = aws_subnet.eks_pub_sub.*.id

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 20
      spot_allocation_strategy                 = var.spot_allocation_strategy
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.eks_worker_nodes.id
      }

      override {
        instance_type = var.instance_types[0]
      }
      override {
        instance_type = var.instance_types[1]
      }
    }
  }

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}