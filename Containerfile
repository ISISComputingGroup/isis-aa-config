# Download and extract dependencies
FROM debian:stable-slim AS download_tomcat

RUN mkdir -p /opt/archiveapp

RUN apt-get update 
RUN apt-get install -y wget

WORKDIR "/opt/archiveapp"

# Edit the Tomcat version here if required
ENV TOMCAT_MAJOR 9
ENV TOMCAT_VERSION 9.0.93

RUN wget https://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz -O tomcat.tar.gz


# Create a JRE containing only what we need using jlink (minimises image size)
FROM eclipse-temurin:21 AS build_jre

RUN $JAVA_HOME/bin/jlink \
         --add-modules ALL-MODULE-PATH \
         --strip-debug \
         --no-man-pages \
         --no-header-files \
         --compress zip-6 \
         --include-locales en-GB,en-US \
         --output /javaruntime

# If EPICS tools needed inside AA container:
# FROM debian:stable-slim AS build_epics_tools
# 
# ENV EPICS_HOST_ARCH linux-x86_64
# RUN apt-get update
# RUN apt-get install -y git gcc g++ make
# RUN git clone --depth 1 https://github.com/epics-base/epics-base /opt/epics-base
# WORKDIR /opt/epics-base
# RUN make -j32


FROM eclipse-temurin:17 AS build_archappl

RUN apt-get update
RUN apt-get install -y git python-is-python3 python3-pip python3-venv
RUN git clone https://github.com/ISISComputingGroup/epicsarchiverap /opt/aa-repo
WORKDIR /opt/aa-repo

ENV ARCHAPPL_SITEID isis
COPY ./sitespecific/ ./src/sitespecific/

# Note: aa has to build on java 17, though can then run on java 21 later.
RUN ./gradlew --parallel
WORKDIR /opt/archiveapp
RUN tar zxf /opt/aa-repo/build/distributions/*.tar.gz


# Run in a slim image to reduce image size
FROM debian:stable-slim AS runtime

RUN apt-get update
# cifs-utils needed at runtime to mount archive share
RUN apt-get install -y cifs-utils

RUN apt-get clean
RUN rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=build_jre /javaruntime $JAVA_HOME
COPY --from=download_tomcat /opt/archiveapp /opt/archiveapp
# If EPICS tools needed inside container
# COPY --from=build_epics_tools /opt/epics-base /opt/epics-base
COPY --from=build_archappl /opt/archiveapp /opt/archiveapp

ENV PATH="${JAVA_HOME}/bin:${PATH}:/opt/epics-base/bin/linux-x86_64:/opt/epics-base/lib/linux-x86_64"

WORKDIR "/opt/archiveapp"

# Note: EPICS_CA_ADDR_LIST set in aa-init.sh
ENV EPICS_CA_AUTO_ADDR_LIST NO
ENV EPICS_CA_MAX_ARRAY_BYTES 20000000

# Container doesn't/can't easily receive beacons. Set CA_MAX_SEARCH_PERIOD instead so that
# we pick up disconnected PVs within 1 minute.
ENV EPICS_CA_MAX_SEARCH_PERIOD 60

# As per GWCONTAINER
ENV EPICS_CA_SERVER_PORT 9264

# Must match one of the appliances defined in appliances.xml
ENV ARCHAPPL_MYIDENTITY archappl_1

# Copy the script to create the data persistence subdirectories at container run-time
# and to run the Tomcat server
COPY aa-init.sh /opt

ENV ARCHAPPL_SHORT_TERM_FOLDER=/storage/sts
ENV ARCHAPPL_MEDIUM_TERM_FOLDER=/storage/mts
ENV ARCHAPPL_LONG_TERM_FOLDER=/storage/lts

# Create mountpoint for archive share
RUN mkdir /storage

CMD [ "/bin/sh", "/opt/aa-init.sh" ]
