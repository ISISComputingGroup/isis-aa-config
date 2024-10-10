# Create the storage subdirectories as soon as the container is running
mkdir -p /storage/sts
mkdir -p /storage/mts
mkdir -p /storage/lts
mkdir -p /storage/logs/tomcat

# Start the Tomcat server
/bin/sh quickstart.sh tomcat.tar.gz
