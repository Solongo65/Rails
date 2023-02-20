# Terraform AWS EKS Cluster
  <img src="https://i.morioh.com/210401/66bbc5af.webp" width="800" height="400"/>


A terraform module to create a managed Kubernetes cluster on AWS EKS. 
Inspired by and adapted from this [guide](https://registry.terraform.io/providers/hashicorp/aws/2.34.0/docs/guides/eks-getting-started)
and source code is available through this [GitHub repo](https://github.com/312-bc/devops-tools-20d-beta/tree/master/terraform_eks_cluster/eks_cluster).

## Assumptions

* You want to create an fully functional EKS cluster on AWS and an autoscaling group of workers for the cluster.
* You want these resources to exist within security groups that allow communication and coordination, which are created within the module.
* You have configured an AWS CLI and have installed kubectl on your machine.
* You have configured a User or Assumed Role with right set of permissions.
* You have custom reuseable AWS resources can be used in different environments.
* You have provisioned S3 bucket with Dynamo.db lock to avoid conflicts with team members.
* You need to mix of demand and spot instances.

## Reference links

* Configure AWS CLI - [AWS_CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
* Assume role  -  [Assume_role](https://aws.amazon.com/premiumsupport/knowledge-center/iam-assume-role-cli/)
* Install kubectl -  [Kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
* Getting Started with AWS EKS - [AWS_EKS](https://registry.terraform.io/providers/hashicorp/aws/2.34.0/docs/guides/eks-getting-started)

## Instructions
#### Note: Makefile is used to automate deployment of the code.

1. Clone source code repository to your local machine and navigate to directory with terraform files:
```
git clone https://github.com/Solongo65/Rail-App.git
cd Rail-App
cd EKS-Cluster-Terraform
cd eks_cluster
```
2. This terraform module uses S3 with Dynamodb lock as a remote backend.\
   We need to create them first:
```
backend-init-plan
make backend-apply
```
3. To initialize terraform and configure remote backend:
```
make eks-init
```
4.  To review AWS EKS resources to be created:
```
make eks-plan
```

5. To create all the resources:\
   This step will also:
   * Configure kubectl so that you can connect to an Amazon EKS cluster
   * Create "aws-auth ConfigMap" to allow nodes to join to EKS cluster
   * Create default storage class for EKS cluster
```
make eks-apply
```

6. To delete EKS cluster and remote backend:
```
make eks-destroy
make backend-destroy
```

## Issues
* When configuring S3 backend - bucket name could be possibly taken or conflict with S3 bucket name convention