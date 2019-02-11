FROM amazoncorretto:8u202

LABEL maintainer="James Ousby <jousby@gmail.com>"

# The below is using Sdkman (http://sdkman.io) to manage the installation of jvm related build tools. 
# The version numbers listed here are sdkman sdk version tags.  Unfortunately to get a list of valid tags to
# enter here you need a working installation of sdkman installed somewhere ('sdk list java'). 
# TODO Once this image is published on dockerhub, update with command to use this image to get
# latest tags. 
# The following page lists other possible tools you can install (http://sdkman.io/sdks.html).
ENV SDKMAN_DIR=/opt/sdkman

ENV GRADLE_VERSION=5.0
ENV MAVEN_VERSION=3.6.0
ENV SBT_VERSION=1.2.8 



# Install required packages for docker, python, aws-cli and sdkman
# Configure docker to start on boot
RUN yum -y update \
    && yum -y install \
        # Used by sdkman 
        which \
        unzip \
        zip \
#        ca-certificates \
#        docker \
#        groff \
#        less \
#        libstdc++ \
#        openssl \
#        openrc \
        # Used by aws cli install
        python-pip \
        # Used by docker
#        libvirt-daemon-driver-lxc.x86_64 \
#        yum-utils \
#        device-mapper-persistent-data \
#        lvm2 \
    && yum clean all \
    && rm -rf /var/cache/yum
    
#RUN amazon-linux-extras install docker 
RUN yum install -y libvirt-daemon-driver-lxc.x86_64 yum-utils device-mapper-persistent-data lvm2 wget curl
RUN yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
RUN cd /tmp && wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y /tmp/epel-release-latest-7.noarch.rpm
RUN yum install -y http://vault.centos.org/centos/7.3.1611/extras/x86_64/Packages/container-selinux-2.9-4.el7.noarch.rpm
RUN yum install -y docker-ce docker-ce-cli containerd.io

# Install sdkman (simple way to add required jvm build tooling)
# Install desired JVM build tools (for a full list of sdkman managed tools see http://sdkman.io/sdks.html)
#RUN curl -s "https://get.sdkman.io" | bash \
#    && echo "sdkman_auto_answer=true" > $SDKMAN_DIR/etc/config \
#    && echo "sdkman_auto_selfupdate=false" >> $SDKMAN_DIR/etc/config \
#    && echo "sdkman_insecure_ssl=true" >> $SDKMAN_DIR/etc/config \
#    && bash -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install gradle ${GRADLE_VERSION}" \
#    && bash -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install maven ${MAVEN_VERSION}" \
#    && bash -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install sbt ${SBT_VERSION}"

# Install AWS Command Line Interface
#RUN pip install awscli

ENTRYPOINT /bin/bash
