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
    envcli config set cache-path "/cache"

############################################################
# Execution
############################################################
ENTRYPOINT []
CMD []
