############################################################
# Base Image
############################################################

# Build Args
ARG BASE_IMAGE

# Base Image
FROM ${BASE_IMAGE:-docker.io/library/docker:19}

############################################################
# Artifacts
############################################################
COPY . /tmp/mpi

############################################################
# Installation
############################################################

RUN chmod -R 755 /tmp/mpi &&\
    /tmp/mpi/install-prerequisites.sh &&\
    /tmp/mpi/install.sh "/usr/local" &&\
    rm -rf /tmp/mpi &&\
    # Configuration
    mkdir -p /cache &&\
    envcli config set cache-path "/cache" &&\
    # Aliases
    envcli install-aliases &&\
    # Permissions
    chmod +x /usr/local/bin/*

############################################################
# Execution
############################################################
ENTRYPOINT []
CMD []
