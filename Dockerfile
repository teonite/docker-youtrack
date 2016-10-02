FROM ubuntu:16.04
MAINTAINER robert@teonite.com

ENV HOME="/root" DEBIAN_FRONTEND=noninteractive

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections

RUN apt-get -q update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:webupd8team/java && apt-get -q update \
 && apt-get -y --force-yes install unzip curl oracle-java8-installer && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/oracle-jdk8-installer

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN \
    mkdir -p /var/lib/youtrack && \
    groupadd --gid 2000 youtrack && \
    useradd --system -d /var/lib/youtrack --uid 2000 --gid youtrack youtrack && \
    chown -R youtrack:youtrack /var/lib/youtrack

RUN export YOUTRACK_VERSION=7.0.27505 && \
    mkdir -p /usr/local/youtrack && \
    mkdir -p /var/lib/youtrack && \
    cd /usr/local/youtrack && \
    echo "$YOUTRACK_VERSION" > version.docker.image && \
    curl -L https://download.jetbrains.com/charisma/youtrack-${YOUTRACK_VERSION}.zip > youtrack.zip && \
    unzip youtrack.zip && \
    rm -f youtrack.zip && \
    chown -R youtrack:youtrack /usr/local/youtrack

RUN cd /usr/local/youtrack && mv youtrack-*/* . && rmdir youtrack-*

######### Install hub ###################
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
USER youtrack
ENV HOME=/var/lib/youtrack
EXPOSE 8080
VOLUME ["/opt/youtrack/conf", "/opt/youtrack/data"]
CMD ["/usr/local/youtrack/bin/youtrack.sh", "run"]