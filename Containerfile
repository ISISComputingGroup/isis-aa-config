FROM eclipse-temurin:21

RUN mkdir -p /opt/archiveapp

WORKDIR "/opt/archiveapp"

RUN wget https://github.com/archiver-appliance/epicsarchiverap/releases/download/1.1.0/archappl_v1.1.0.tar.gz -O archappl.tar.gz
RUN tar zxf archappl.tar.gz
RUN rm -f archappl.tar.gz

RUN wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.91/bin/apache-tomcat-9.0.91.tar.gz -O tomcat.tar.gz

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
