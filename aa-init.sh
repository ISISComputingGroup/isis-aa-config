mount -t cifs -o domain="$cifs_domain",username="$cifs_user",password="$cifs_pass",uid=$(id -u),gid=$(id -g),rw //ISISARVR3/ArchiveApplianceTest\$ /storage || {
    echo 'mount failed; ensure you are passing CIFS domain/user/pass from .env (tried logging in as $cifs_domain\$cifs_user)' ;
    exit 1; 
}

# Create the storage subdirectories as soon as the container is running
mkdir -p /storage/sts
mkdir -p /storage/mts
mkdir -p /storage/lts
mkdir -p /storage/logs/tomcat

# Get the public ISIS ip address of the host, use port 9264 for GWCONTAINER
export EPICS_CA_ADDR_LIST=$(getent hosts $container_host_hostname | awk '{ print $1 }' | grep -F 130.246. | sed -e 's/$/:9264/' | tr '\n' ' ')

# Start the Tomcat server
/bin/sh quickstart.sh tomcat.tar.gz
