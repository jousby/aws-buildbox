FROM amazonlinux:2.0.20190228

LABEL maintainer="James Ousby <jousby@gmail.com>"

# The below is using Sdkman (http://sdkman.io) to manage the installation of jvm related build tools. 
# The version numbers listed here are sdkman sdk version tags.  Unfortunately to get a list of valid tags to
# enter here you need a working installation of sdkman installed somewhere ('sdk list java'). 
# TODO Once this image is published on dockerhub, update with command to use this image to get
# latest tags. 
# The following page lists other possible tools you can install (http://sdkman.io/sdks.html).
ENV SDKMAN_DIR=/opt/sdkman

# For stability / deterministic builds, fix the versions of tools being installed rather than just use 'latest'.
ENV AWS_CLI_VERSION=1.16.140
ENV AWS_SAM_CLI_VERSION=0.14.2
ENV DOCKER_VERSION=18.06.1
ENV JAVA_VERSION=8.0.202-amzn
ENV GRADLE_VERSION=5.3.1
ENV MAVEN_VERSION=3.6.1
ENV SBT_VERSION=1.2.8 
ENV NODE_VERSION=10.15.3
ENV CDK_VERSION=0.27.0

# Install required packages for python, aws-cli and sdkman
RUN yum -y update \
    && yum -y install \
        which \
        unzip \
        zip \
        python-pip \
        python-devel \
        gcc* \
        tar.x86_64 \
        gzip \
    && yum clean all \
    && rm -rf /var/cache/yum

# Install AWS CLI and Serverless Application Model CLI
RUN pip install awscli==${AWS_CLI_VERSION}
RUN pip install aws-sam-cli==${AWS_SAM_CLI_VERSION}
RUN yum -y remove python-devel
    
# Install docker
RUN amazon-linux-extras install docker=${DOCKER_VERSION}

# Install sdkman (simple way to add required jvm build tooling)
# Install desired JVM build tools (for a full list of sdkman managed tools see http://sdkman.io/sdks.html)
RUN curl -s "https://get.sdkman.io" | bash \
    && echo "sdkman_auto_answer=true" > $SDKMAN_DIR/etc/config \
    && echo "sdkman_auto_selfupdate=false" >> $SDKMAN_DIR/etc/config \
    && echo "sdkman_insecure_ssl=true" >> $SDKMAN_DIR/etc/config \
    && bash -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install java ${JAVA_VERSION}" \
    && bash -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install gradle ${GRADLE_VERSION}" \
    && bash -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install maven ${MAVEN_VERSION}" \
    && bash -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install sbt ${SBT_VERSION}"

# Install nvm (node version manager) and install node
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
RUN /bin/bash -c "source /root/.nvm/nvm.sh; nvm install ${NODE_VERSION}"

# Install AWS Cloud Development Kit CLI
RUN /bin/bash -c "source /root/.nvm/nvm.sh; npm i -g aws-cdk@${CDK_VERSION}"

# Setup up the root account to load all the required tools on entry
RUN { \
  echo 'dockerd &> /tmp/docker.log &'; \
  echo 'source ${SDKMAN_DIR}/bin/sdkman-init.sh'; \
  echo 'export NVM_DIR=~/.nvm'; \
  echo '. ~/.nvm/nvm.sh'; \
  } > /root/.bashrc

ENTRYPOINT /bin/bash