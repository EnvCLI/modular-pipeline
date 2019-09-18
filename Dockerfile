############################################################
# Dockerfile
############################################################

# Set the base image
FROM docker.io/docker:19

############################################################
# Configuration
############################################################
ENV VERSION "0.0.1"

############################################################
# Artifacts
############################################################
COPY .envcli.yml /etc/envcli/.envcli.yml
COPY actions/* /usr/local/bin/
COPY stages/* /usr/local/bin/

############################################################
# Installation
############################################################

RUN echo "System Packages ..." &&\
    apk add --no-cache curl bash &&\
    echo "Tools ..." &&\
    echo "-> Getting EnvCLI ..." &&\
    curl -L -s -o /usr/local/bin/envcli https://dl.bintray.com/envcli/golang/envcli/v0.6.1/envcli_linux_amd64 &&\
    chmod +x /usr/local/bin/envcli &&\
    echo "-> EnvCLI Configuration" &&\
    mkdir -p /etc/envcli &&\
    envcli config set global-configuration-path /etc/envcli &&\
    chmod 644 /etc/envcli/.envcli.yml &&\
    echo "-> Getting NormalizeCI ..." &&\
    curl -L -s -o /usr/local/bin/normalizeci https://dl.bintray.com/envcli/golang/normalize-ci/v0.1.0/linux_amd64 &&\
    chmod +x /usr/local/bin/normalizeci &&\
    echo "-> Installing EnvCLI Aliases" &&\
    envcli install-aliases &&\
    echo "-> Executable permissions" &&\
    chmod +x /usr/local/bin/*

############################################################
# Execution
############################################################
ENTRYPOINT []
CMD []
