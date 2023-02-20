cluster_name = eks_cluster

### Remote backend
backend-init-plan:
	cd remote_backend && terraform init && terraform plan

backend-apply:	
	cd remote_backend && terraform apply -auto-approve	

### EKS Cluster		
eks-init:
	terraform init -backend-config=backend.tfvars

eks-plan:
	terraform plan

eks-apply:
	terraform apply -auto-approve
	aws eks update-kubeconfig --name $(cluster_name)
	kubectl apply -f aws_auth/config_map_aws_auth.yaml
	sleep 60
	kubectl get nodes
	kubectl apply -f eks_storage_class.yaml

eks-destroy:
	terraform destroy -auto-approve
	rm -rf aws_auth
	rm -rf .terraform
	rm -rf .terraform.lock.hcl


backend-destroy:
	cd remote_backend && \
	terraform destroy -auto-approve && \
	rm -rf .terraform && \
	rm -rf .terraform.lock.hcl && \
	rm -rf  terraform.tfstate && \
	rm -rf  terraform.tfstate.backup
