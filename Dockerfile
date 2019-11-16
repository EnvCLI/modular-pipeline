############################################################
# Base Image
############################################################

# Build Args
ARG BASE_IMAGE

# Base Image
FROM ${BASE_IMAGE:-docker.io/library/docker:19}

############################################################
# Configuration
############################################################
ENV VERSION "0.0.1"

############################################################
# Artifacts
############################################################
COPY . /tmp/mpi

############################################################
# Installation
############################################################

RUN echo "System Packages ..." &&\
    apk add --no-cache curl bash gettext git grep &&\
    echo "Tools ..." &&\
    echo "-> Getting EnvCLI ..." &&\
    curl -L -s -o /usr/local/bin/envcli https://dl.bintray.com/envcli/golang/envcli/v0.6.4/envcli_linux_amd64 &&\
    chmod +x /usr/local/bin/envcli &&\
    echo "-> Pipeline" &&\
    chmod -R 755 /tmp/mpi &&\
    /tmp/mpi/install.sh /usr/local &&\
    rm -rf /tmp/mpi &&\
    echo "-> EnvCLI Configuration" &&\
    mkdir -p /cache &&\
    envcli config set cache-path "/cache" &&\
    echo "-> Installing EnvCLI Aliases" &&\
    envcli install-aliases &&\
    echo "-> Executable permissions" &&\
    chmod +x /usr/local/bin/*

############################################################
# Execution
############################################################
ENTRYPOINT []
CMD []
