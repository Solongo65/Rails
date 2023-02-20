<h1 align="center"><b>RAILS APP</b></h3> ..


<p>A sample environment to run a Rails New application.</p> 

[To get started with Rails](https://nicolasiensen.github.io/2022-02-01-creating-a-new-rails-application-with-docker/)

- the `rails new .` command is a convenient way to get started with a new Ruby on Rails application by generating a application skeleton in . project folder:
  -  Setting up a Gemfile with the necessary gems for a basic Rails application
  - Setting up a default database configuration file
  -  Creating a basic directory structure for models, views, and controllers
  Setting up a default welcome page

Dockerfile:

- `FROM --platform=linux/amd64 ruby:3.1.0-alpine`

  - This sets the base image for the Dockerfile. The image being used is ruby:3.1.0-alpine which is a lightweight Alpine Linux distribution with Ruby 3.1.0 pre-installed. The --platform=linux/amd64 flag specifies that the image is intended for use on x86-64 (64-bit) architecture.

- `RUN apk update && apk add --no-cache build-base postgresql-dev tzdata`
  - This installs system dependencies needed by the application. The apk update command updates the package index in the Alpine Linux distribution, while apk add installs the specified packages. In this case, build-base includes common build tools, postgresql-dev includes development libraries and headers for PostgreSQL, and tzdata includes timezone data.

- `WORKDIR /app`
  -  This sets the working directory for the container to /app. This is where the application code will be copied to later in the Dockerfile.
- `COPY Gemfile Gemfile.lock ./`
  - This copies the Gemfile and Gemfile.lock from the current directory on the host machine to the current directory in the Docker container. These files contain a list of Ruby gems required by the Rails application.
- `RUN bundle install --jobs $(nproc) --retry 3`
  - RUN bundle install --jobs $(nproc) --retry 3:  This command runs the bundle install command, which installs the Ruby gems specified in the Gemfile into the Docker container.
- `COPY . .`
  - This copies the application code into the container. The . means that all files in the current directory (including subdirectories) will be copied into the container.
- `EXPOSE 3000`
  - This exposes port 3000 on the container. This is necessary to allow traffic to be routed to the Rails server when the container is running.
- `CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]`
  - This copies the Gemfile and Gemfile.lock files from the host machine into the container and installs the required gems using the bundle install command.


This project uses the following tools:

* [Terraform](<#Terraform>)

* [Jenkins](<#Jenkins>)

* [Kubernetes](<#Kubernetes>)


## Content
- [Introduction](#Introduction)
  - [Terraform](#Terraform)
  - [Jenkins](#Jenkins)
  - [Kubernetes](#Kubernetes)
- [Diagram](#Diagram)
- [Configuration](#Configuration)
  - [Step 1: Deploying a containerized cluster on AWS](#Step-1-Deploying-a-containerized-cluster-on-AWS)
  - [Step 2: Setting up Jenkins pipelines](#Step-2-Setting-up-Jenkins-pipelines)
  - [Step 3: Deploying Rails application](#Step-3-Deploying-Rails-application)
- [Considerations](#Considerations)
  - [Future Improvements](#Future-Improvements)
  - [Problems I faced](#Problems-I-faced)


## What is Rails?
Rails is a web application development framework written in the Ruby programming language. It makes the assumption that there is a "best" way to do things

### The Rails philosophy includes two major guiding principles:

* Don't Repeat Yourself: DRY is a principle of software development which states that "Every piece of knowledge must have a single, unambiguous, authoritative representation within a system". By not writing the same information over and over again, our code is more maintainable, more extensible, and less buggy.

* Convention Over Configuration: Rails has opinions about the best way to do many things in a web application, and defaults to this set of conventions, rather than require that you specify minutiae through endless configuration files.

## Terraform
Terraform is an infrastructure as code tool that lets you define both cloud and on-prem resources in human-readable configuration files that you can version, reuse, and share. You can then use a consistent workflow to provision and manage all of your infrastructure throughout its lifecycle. Terraform can manage low-level components like compute, storage, and networking resources, as well as high-level components like DNS entries and SaaS features.

## Kubernetes
Kubernetes, also known as K8s, is an open-source system for automating deployment, scaling, and management of containerized applications. Kubernetes groups containers that make up an application into logical units for easy management and discovery. Kubernetes builds upon 15 years of experience of running production workloads at Google, it's capable of creating highly available, secure, and scallable applications.

## Jenkins
Jenkins is an open-source automation tool written in Java with plugins built for continuous integration. Jenkins is used to build and test software projects continuously making it easier for developers to integrate changes to the project, and making it easier for users to obtain a fresh build. It also allows you to continuously deliver your software by integrating with a large number of testing and deployment technologies.

## Functionality

![](https://file%2B.vscode-resource.vscode-cdn.net/Users/choko/Desktop/App/G2/Untitled%20Diagram.drawio%20%281%29.png?version%3D1676560441802)

## Step 1: Deploying a containerized cluster on AWS

- I created and attached a fully functional EKS cluster that have self managed EKS node group.
- is a managed service that you can use to run Kubernetes on AWS without needing to install, operate, and maintain your own Kubernetes control plane or nodes. Key features to consider are availability, security and cost for your application. It also can be integrated with many AWS services.

* Including the following capabilities:

    - Amazon ECR for container images
    - Elastic Load Balancing for load distribution
    - IAM for authentication
    - Amazon VPC for isolation
    - Self-managed Linux nodes

* Advantages of the EKS managed in comparison to self-managed node groups: 
    -  We don’t need to separately provision or register the Amazon EC2 instances that provide compute capacity to run your Kubernetes applications. You can create, update, or terminate nodes for your cluster with a single operation.
* Disadvantages of the EKS managed nodes:
    -  AMI versions aren’t up-to-date for managed worker groups (not the latest version). You cannot roll back a node group to an earlier Kubernetes version or AMI version. Not support for mixed instances! Only spot or demand instance. Can not run containers that require Windows.



## Step 2: Setting up Jenkins pipelines
-I created and attached a Jenkins pipeline with 3 users (Build, Read, Admin) in the Casc file, I configured a job to run and scan the repo through JCasc. Jenkins image has all the necessary pluging and configs needed to run the Rails app smoothly. Jenkins leverage service account to get access to ECR to push and pull images. 
 
JCasC is part of the "Configuration as Code" movement in software development, with JCasC, you can define the configuration of Jenkins, including jobs, plugins, credentials, and global settings, in a code repository and manage it like any other code. This makes it easy to version control, test, and replicate Jenkins configurations across different environments. 

Using the Configuration as Code plugin is a new and better way to customize Jenkins, so I focused on this method. It is an automated way of configuring Jenkins and eliminates the chance for errors.

To access Jenkins Master UI- http://jenkins-master.otgonbayarsolongo.com/login?from=%2F

## Step 3: Deploying Rails application

Whenever there's a push to GitHub, a payload will be send to Jenkins Master and trigger it. Jenkins master will create a jenkins agent pod that will do all the work. The worker pod will clone the repo and read the Jenkinsfile for instructions on how to run the job. The Jenkinsfile uses a Makefile with targets to:

1. `Build` image using the provided docker file. 
2. `Login` to AWS ECR. 
3. `Push` Image to AWS ECR. 4. Deploy the application using a provided manifest in the repo.
 
Since there's no hostname provided, I created (DNS) Route 53, with record type that we can access the App using ingress defined. 

To access the apps, we will use:

http://rails-app.otgonbayarsolongo.com

## Considerations

### Future Improvements

1. Run Rails App as a statefulSet for high consistency.
2. More security practices can be implemented (WAF, Encrypted DB, Network Policy, Service Accounts ..).
3. All the above project, including the Rails app, EKS, and Jenkins itself. can be deployed automatically through a 3rd Jenkins pipeline.

### Problems I faced

1. Lots of incompatible dependencies.
2. Conflict with arm64 and amd64 architecture.
3. Cache with docker images.
2. Outdated Dependencies.
3. Base image needs much plugins, which increased the size of the Rails app image.
4. JCASC: Configuring Jenkins through code tends to be VERY complex. It was hard to find a right base image.
5. Config.hosts blocked by Rails 
6. Needed to troubleshoot a lot

Thank you G2