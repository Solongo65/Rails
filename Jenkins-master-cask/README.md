
## What is Jenkins and why do we use it?
Automation, including CI/CD and test automation, is one of the key practices that allow DevOps teams to deliver “faster, better, cheaper” technology solutions. [Jenkins](https://www.jenkins.io/doc/) is the most popular open source CI/CD tool on the market today and is used in support of DevOps, alongside other cloud native tools. Jenkins is used to build and test your product continuously, so developers can continuously integrate changes into the build. 

You can read more about jenkins features and use cases [here](https://www.spiceworks.com/tech/devops/articles/what-is-jenkins/#:~:text=Jenkins%20is%20a%20Java%2Dbased,to%20get%20a%20new%20build.).


## Goals
1. Create [Jenkins server in k8s](https://www.jenkins.io/doc/book/installing/kubernetes/)
2. Be able to apply configurations dynamically, with no manual intervention
3. Inject secrets used by jenkins using k8s best practices.


## Overview 
We are setting up Jenkins master in EKS cluster, using custom image which is stored in ECR, with dynamic setup for cloud, user and job configurations.  Jenkins secrets such as users & credentials, github repo and access tokens are stored in AWS SSM Parameter store which will be injected into jenkins-master pod via k8s. We use IAM roles and policies to be able to access above mentioned AWS resources. Finally, in route53 we create a record for jenkins.centos22b.exchangeweb.net to access jenkins. 

![Jenkins Continuous Integration](https://user-images.githubusercontent.com/111542892/205757143-f0d86c7c-05c3-47be-85ce-b9f12709a3de.png)

### Pre-requisites
You need to have the following in your environment to run this locally or create your own: 
- [Docker](https://docs.docker.com/get-docker/) installed on your machine
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) command line tool 
- [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed and configured to access your cluster and other AWS resources as required
	- Install ingress controller: 
 	
	`kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/aws/deploy.yaml`


## How to run current setup on your local?

1. Clone this repo to your local
2. Follow commands below:
```
cd Jenkins-master-cask

make (path/target)

```

-------------------

# Dockerfile: 
![# pulling jenkins image from docker repository](https://user-images.githubusercontent.com/111542892/205759066-14ef0a39-b12e-442a-8313-ea6757924edc.png)

The base image I used was Jenkins:2.378 and customized it. 
The JAVA_OPTS environment variable defines the instructions to:
1. ignore the Jenkins initial set-up wizard, so Jenkins will not ask for the temporary admin password at initial set-up. It loads the login page directly.

![Getting Started](https://user-images.githubusercontent.com/111542892/205759238-62892442-1a30-4d88-9e1b-206b9702afd2.png)


2. Disable the client IP check, which is a safety feature from Jenkins to preserve the client IP. This could give some proxy errors if not disabled. 

3. Plugins.txt
- aws-credentials
- aws-parameter-store
- configuration-as-code-secret-ssm

-------------------

# Deployment YAML

Everything in this deployment file is to configure and deploy the Jenkins master.


# Jenkins UI

As you can see the JAVA_OPTS variable I set in the Dockerfile worked and it disabled the Jenkins initial set-up wizard and I landed on the login page. 

![Jenkins first user](https://user-images.githubusercontent.com/111542892/206333749-aa8c41c2-f061-460d-93ef-1ccb8591080e.png)


![Welcome to Jenkins!](https://user-images.githubusercontent.com/111542892/205761070-04e13581-8818-4e30-83b9-4b0fce13d816.png)

# Jcasc file:

- There is a plugin released by CloudBees called Configuraton as Code. Once installed, this plugin creates a configuration file inside Jenkins in a "human readable" yaml format: in short it is referred to as JCasC (Jenkins Configuration as Code)
- JCasC is part of the "Configuration as Code" movement in software development, which aims to manage the configuration of software systems using code, rather than through manual configuration. By using JCasC, you can achieve greater reproducibility, consistency, and scalability in your Jenkins setups, while reducing the risk of human error and ensuring greater agility and adaptability.
- You can access and download the file through the Jenkins UI. It contains the current configurations from Jenkins. 
- JCasC can be used to configure a new Jenkins instance from scratch, or to import and manage an existing Jenkins instance's configuration. This can be useful for managing complex Jenkins setups that involve multiple instances, and for enforcing consistency and best practices across your organization's Jenkins instances.
- Loading credentials from AWS SSM Parameter store and automating this process: The traditional method to achieve this was using init groovy scripts in combination with sed replacement. However there are several plugins which you can download and configure to achieve the same thing in an easier way. These plugins are:
	- aws-credentials
    - aws-parameter-store
	- configuration-as-code-secret-ssm
- Policy to give read permission from the AWS SSM Parameter store
- Attached this policy to the existing IAM role for the EC2 instances in the EKS cluster 

![Option+S](https://user-images.githubusercontent.com/111542892/205762079-559bc0b9-2847-4a54-a408-08c3f33c8a05.png)

To link the secrets to Jenkins, I added the necessary settings to the configurations in the Jcasc file to pull the secret from the Parameter Store. This is a pre-defined syntax and config that you have to use in the Jcasc file, and it works hand in hand with configuration-as-code-secret-ssm plugin that was installed during the creation of the image in docker.

![Final Project  devops-tools-22b-ubuntu  jenkins-master  @ jenkins-casc yan](https://user-images.githubusercontent.com/111542892/205762892-2709bbb5-850b-429a-819b-533ecc52433f.png)

- In order for the Jcasc file to be injected in the pod I used a Configmap, created from the Jcasc file, and mounted as a volume into the pod
- In the Makefile I added two additional targets to automate the process: 
	- deletecm - to delete the existing configmap (we have to use "-" in front of the command, which tells Makefile to ignore if there is an error)
	- configmap (depending on deletecm) - to recreate a new configmap with the current jcasc file data with the changes (if I made any changes or updates).

![Final Project  devops-tools-22b-ubuntu  jenkins-master  @ jenkins-casc yan](https://user-images.githubusercontent.com/111542892/205762892-2709bbb5-850b-429a-819b-533ecc52433f.png)

- You can define your branch in Jcask file, It will automitcally run the job. 
![script](https://user-images.githubusercontent.com/111542892/205763342-dfc61287-1732-4d4e-b2fd-12bdf1363be5.png)

Log in Jenkins: http://jenkins-master.otgonbayarsolongo.com/login?from=%2F

--------------
# Resources:
https://plugins.jenkins.io/configuration-as-code/

https://docs.cloudbees.com/docs/cloudbees-jenkins-platform/latest/casc-oc/

https://gerg.dev/2020/06/creating-a-job-dsl-seed-job-with-jcasc/

https://tomgregory.com/inject-secrets-from-aws-into-jenkins-pipelines/

