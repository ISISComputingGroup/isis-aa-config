# Download and extract dependencies
FROM debian:stable-slim AS download_deps

RUN mkdir -p /opt/archiveapp

RUN apt-get update 
RUN apt-get install -y wget

WORKDIR "/opt/archiveapp"

RUN wget https://github.com/archiver-appliance/epicsarchiverap/releases/download/1.1.0/archappl_v1.1.0.tar.gz -O archappl.tar.gz
RUN tar zxf archappl.tar.gz
RUN rm -f archappl.tar.gz

RUN wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.91/bin/apache-tomcat-9.0.91.tar.gz -O tomcat.tar.gz


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

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=jre_build /javaruntime $JAVA_HOME
COPY --from=download_deps /opt/archiveapp /opt/archiveapp
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR "/opt/archiveapp"

# This is very much sub-optimal - pointing at a gateway directly for testing.
# This is the R55 gateway meaning you can access PVs in R3 and R80, but NOT R55
# Probably the correct fix is to run another gateway on the local instruments only
# listening to / used by containers and forwarding to the outside world.
ENV EPICS_CA_ADDR_LIST 130.246.54.107
ENV EPICS_CA_AUTO_ADDR_LIST NO
ENV EPICS_CA_MAX_ARRAY_BYTES 20000000

# TODO: is this really what we want?
ENV ARCHAPPL_MYIDENTITY localhost

CMD [ "/bin/sh", "quickstart.sh", "tomcat.tar.gz" ]
