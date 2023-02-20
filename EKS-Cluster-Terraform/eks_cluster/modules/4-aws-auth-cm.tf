### Configure Kubernetes to permit the nodes to register
locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks_wn_role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}
output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

### AWS Auth config map yaml file
resource "local_file" "boo" {
  content  = local.config_map_aws_auth
  filename = "./aws_auth/config_map_aws_auth.yaml"
}