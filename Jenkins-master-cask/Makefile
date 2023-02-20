account = $(shell aws sts get-caller-identity --query "Account" --output text)
repo = jenkins-master
region = us-east-1
namespace = jenkins
version = 1.0

testing:
	@echo current image version is $(version)

build: testing
	docker build -t $(repo):$(version) . --no-cache

login: build
	aws ecr get-login-password --region $(region) | docker login --username AWS --password-stdin $(account).dkr.ecr.$(region).amazonaws.com

push: login
	docker tag $(repo):$(version) $(account).dkr.ecr.$(region).amazonaws.com/$(repo):$(version)
	docker push $(account).dkr.ecr.$(region).amazonaws.com/$(repo):$(version)

deploy: namespace configmap
	cat deployment.yaml | sed "s/ACCT_NUMBER/$(account)/g;s/IMAGE_VERSION/$(version)/g;s/CUSTOM_NAMESPACE/$(namespace)/g" | kubectl -n $(namespace) apply -f -

namespace: 
	cat namespace.yaml | sed "s/CUSTOM_NAMESPACE/$(namespace)/g" | kubectl apply -f -

deletecm:
	- kubectl delete configmap jenkins-casc-cm -n $(namespace)

configmap: deletecm
	kubectl create configmap jenkins-casc-cm --from-file=./jenkins-casc.yaml -n $(namespace)

delete:
	cat deployment.yaml | sed "s/ACCT_NUMBER/$(account)/g;s/IMAGE_VERSION/$(version)/g;s/CUSTOM_NAMESPACE/$(namespace)/g" | kubectl -n $(namespace) delete -f -
	kubectl delete configmap jenkins-casc-cm -n $(namespace)
	cat namespace.yaml | sed "s/CUSTOM_NAMESPACE/$(namespace)/g" | kubectl delete -f -
