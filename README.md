## AWS Buildbox 

[![Build Status](https://travis-ci.org/jousby/aws-buildbox.svg?branch=master)](https://travis-ci.org/jousby/aws-buildbox)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jousby/aws-buildbox/blob/master/LICENSE)

A docker image for use in AWS CodeBuild as a build environment that is AWS all the way down. If your targeted runtime environment is AWS then you may find this image useful
to use the same environment (Amazon Linux) and jvm (Amazon Corretto) in your build process as you do at runtime.


## What's Installed

* Amazon Linux 2
* Amazon Corretto (AWS OpenJDK)
* AWS CLI
* AWS SAM CLI
* AWS CDK CLI
* Docker
* Python
* Node
* Sdkman (and the folldwing sdkman managed tools)
  * Maven
  * Gradle
  * Sbt

To see specific versions of the tools installed in a particular release refer to the [CHANGELOG](https://github.com/jousby/aws-buildbox/blob/master/CHANGELOG.md).

This image makes use of [Sdkman](http://sdkman.io) to manage the JVM related build tools.

## License

View the [LICENSE](https://github.com/jousby/simple-buildbox/blob/master/LICENSE) for the software contained in this image.

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
