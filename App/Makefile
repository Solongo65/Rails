version = 1.0
account = $(shell aws sts get-caller-identity --query "Account" --output text)
repo = rails-app
region = us-east-1
stage = $(current_stage)
namespace = rails-app


build:
	docker build -t $(repo):$(version) . 

login: build
	aws ecr get-login-password --region $(region) | docker login --username AWS --password-stdin $(account).dkr.ecr.$(region).amazonaws.com

push: login
	docker tag $(repo):$(version) $(account).dkr.ecr.$(region).amazonaws.com/$(repo):$(version)
	docker push $(account).dkr.ecr.$(region).amazonaws.com/$(repo):$(version)
	
namespace: push
	cat Kubernetes/namespace.yaml | sed "s/NAMESPACE/$(namespace)/g" | kubectl apply -f -

deploy: namespace
	cat Kubernetes/deploy.yaml | sed "s/ACCT_NUMBER/$(account)/g;s/NAMESPACE/$(namespace)/g;s/REPO/$(repo)/g;s/VERSION/$(version)/g;s/REGION/$(region)/g" | kubectl apply -f -