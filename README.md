## Simple Buildbox 

[![Build Status](https://travis-ci.org/jousby/simple-buildbox.svg?branch=master)](https://travis-ci.org/jousby/simple-buildbox)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jousby/simple-buildbox/blob/master/LICENSE)

A docker image that makes it easy to package up your build toolchains and in particular, JVM build tools.

The initial use case for creating this image was for use as a custom build image in AWS CodeBuild. By default AWS CodeBuild provides you with several [Ubuntu based images](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html) that should cover a large number of usecases. However if you are after an earlier/later version of specific tools or tools that aren't in the base images then you can use this project to build  your own build image.

While AWS CodeBuild was the initial driver for creating this image there is nothing that would stop this from being a general purpose image for development teams to package up a golden source / reference toolchain stack for building their applications (both on their local machines and in a CI tool like Jenkins).

## What's Installed

By default the image is based on Alpine Linux with the following tools installed:

* alpine linux
* docker
* aws cli
* python
* sdkman (and the folldwing sdkman managed tools)
  * java
  * maven
  * gradle
  * sbt

To see specific versions of the tools installed in a particular release refer to the [CHANGELOG](https://github.com/jousby/simple-buildbox/blob/master/CHANGELOG.md).

This image makes use of [Sdkman](http://sdkman.io) to manage the JVM related build tools. The neat thing about this is that:

* It's a one line change to edit the Dockerfile to add one of the many SDK's managed by Sdkman.
* It's a one line change to edit the Dockerfile to remove a tool you don't need.
* At build runtime you can easily switch the version of java, maven, sbt etc that you are using just for that particular run.

## Usage

### How To Use In AWS CodeBuild

AWS CodeBuild is a managed service that lets you define and run build jobs without having to operate your own build infrastructure. In conjunction with AWS CodePipeline you can achieve a lot of the functionality that you get out of a CI tool like Jenkins. The advantage being that you don't have to manage/patch any servers and you don't have to worry about scaling it or making it highly available.

Steps to use this image in AWS CodeBuild:

1. Navigate to the AWS CodeBuild service.
1. Kick off the create new build wizard and in the build environment section:
   1. Choose Enivronment Image => "Specify a custom Docker Image"
   1. Choose Evnironment Type => "Linux"
   1. Choose Custom Image Type => "Other"
   1. For Custom Image Id => "jousby/simple-buildbox:latest"
   1. For Build Specification your options are to enter them directly in the wizard or reference a 'buildspec.yml' file in your project source code. Either way here is an example buildspec leveraging this image:
   ```yaml
   version: 0.2

   phases:
     pre_build:
       commands:
         - echo "Starting docker daemon"
         - nohup /usr/bin/dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 --storage-driver=overlay&
         - timeout -t 15 sh -c "until docker info; do echo .; sleep 1; done"
         - echo "Logging in to Amazon ECR"
         - $(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)
         - REPOSITORY_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME
         - IMAGE_TAG=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | head -c 8)
         - echo $IMAGE_TAG
     build:
       commands:
         - echo "Build started on `date`"
         - echo "Running mvn install"
         - bash -c "source /opt/sdkman/bin/sdkman-init.sh && mvn install"
         - echo "Build and tag the Docker image"
         - docker build -t $REPOSITORY_URI:$IMAGE_TAG .
         - docker tag $REPOSITORY_URI:$IMAGE_TAG $REPOSITORY_URI:latest
     post_build:
       commands:
         - echo "Build completed on `date`"
         - echo "Pushing the Docker image"
         - docker push $REPOSITORY_URI:$IMAGE_TAG
         - docker push $REPOSITORY_URI:latest
         - echo Writing image definition file...
         - printf '[{"name":"MyJvmContainer","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG > imagedef.json

   artifacts:
     files: imagedef.json

   cache:
     paths:
       - '/root/.m2/**/*'%
   ```

Note: If you want to leverage caching of library dependencies in your build the last three lines in that spec are not enough. There is a section in the build wizard where you also need to specify an S3 bucket for the cached artifacts to live in.

Note 2: If you publish an artifact as part of the output for this build you also need to configure a section on build artifacts in the build wizard that details an S3 bucket to push artifacts to.

Note 3: You need to inject two evironment variables into this build to make it work ("IMAGE_REPO_NAME", "AWS_ACCOUNT_ID") which are used to build the name of your Amazon ECR repo.

### Publish Your Own Forked Version of this Image to Amazon ECR

If any of the released versions of this image don't satisfy your requirements then forking this repo and building your own image is an obvious option. Rather than publish it on Dockerhub just so you can reference it from AWS CodeBuild though another option is to push your customised image to Amazon ECR (Elastic Container Registry). ECR provides you with a private Container registry within your AWS account.

[Instructions for pushing images to Amazon ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)

Once you have published to ECR then the CodeBuild wizard will allow you to select Amazon ECR as the source of your custom image and will then prepopulate the image dropdown with the available images in your ECR.

Steps to use your published image in ECR

1. Navigate to the AWS CodeBuild service.
1. Kick off the create new build wizard and in the build environment section:
   1. Choose Enivronment Image => "Specify a custom Docker Image"
   1. Choose Evnironment Type => "Linux"
   1. Choose Custom Image Type => "Amazon ECR"
   1. For Amazon ECR Repository => Select your repo from the dropdown
   1. For Amazon ECR Image => Select your image from the dropdown

## License

View the [LICENSE](https://github.com/jousby/simple-buildbox/blob/master/LICENSE) for the software contained in this image.

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
