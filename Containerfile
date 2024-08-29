# Download and extract dependencies
FROM debian:stable-slim AS download_deps

RUN mkdir -p /opt/archiveapp

RUN apt-get update 
RUN apt-get install -y wget

WORKDIR "/opt/archiveapp"

# Edit the Tomcat version here if required
ENV TOMCAT_MAJOR 9
ENV TOMCAT_VERSION 9.0.93

RUN wget https://github.com/archiver-appliance/epicsarchiverap/releases/download/1.1.0/archappl_v1.1.0.tar.gz -O archappl.tar.gz
RUN tar zxf archappl.tar.gz
RUN rm -f archappl.tar.gz

RUN wget https://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz -O tomcat.tar.gz


# Create a JRE containing only what we need using jlink (minimises image size)
FROM eclipse-temurin:21 as jre_build

RUN $JAVA_HOME/bin/jlink \
         --add-modules ALL-MODULE-PATH \
         --strip-debug \
         --no-man-pages \
         --no-header-files \
         --compress zip-6 \
		 --include-locales en-GB,en-US \
         --output /javaruntime


# Run in a slim image to reduce image size
FROM debian:stable-slim

RUN apt-get update
# Facilitate ip tool for network diagnostics during dev.
RUN apt-get install -y iproute2
RUN apt install iputils-ping -y

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=jre_build /javaruntime $JAVA_HOME
COPY --from=download_deps /opt/archiveapp /opt/archiveapp
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR "/opt/archiveapp"

# This is very much sub-optimal - pointing at a gateway directly for testing.
# This is the R55 gateway meaning you can access PVs in R3 and R80, but NOT R55
# Probably the correct fix is to run another gateway on the local instruments only
# listening to / used by containers and forwarding to the outside world.

# IP of host where local gateway is running

# The following is the localhost gateway
#ENV EPICS_CA_ADDR_LIST 130.246.49.125
#ENV EPICS_CA_ADDR_LIST host.docker.internal
#ENV EPICS_CA_ADDR_LIST 192.168.127.255

# The following is the R55 gateway
ENV EPICS_CA_ADDR_LIST 130.246.54.107

ENV EPICS_CA_AUTO_ADDR_LIST NO
ENV EPICS_CA_MAX_ARRAY_BYTES 20000000

# TODO: is this really what we want?
ENV ARCHAPPL_MYIDENTITY localhost

# Ian: 
# Folders we store data and logs in
# (may mount them from the host machine):
RUN mkdir -p /storage/sts
RUN mkdir -p /storage/mts
RUN mkdir -p /storage/lts
RUN mkdir -p /storage/logs
RUN mkdir -p /storage/logs/tomcat
#RUN mkdir -p /opt/archiveapp/quickstart_tomcat/apache-tomcat-$TOMCAT_VERSION/
#RUN rm -rf /opt/archiveapp/quickstart_tomcat/apache-tomcat-$TOMCAT_VERSION/logs
#RUN ln -s /storage/logs/tomcat /opt/archiveapp/quickstart_tomcat/apache-tomcat-$TOMCAT_VERSION/logs
ENV ARCHAPPL_SHORT_TERM_FOLDER=/storage/sts
ENV ARCHAPPL_MEDIUM_TERM_FOLDER=/storage/mts
ENV ARCHAPPL_LONG_TERM_FOLDER=/storage/lts

CMD [ "/bin/sh", "quickstart.sh", "tomcat.tar.gz" ]
#CMD [ "/bin/bash"]

