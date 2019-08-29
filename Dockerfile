############################################################
# Dockerfile
############################################################

# Set the base image
FROM docker.io/envcli/envcli:0.5.1

############################################################
# Labels
############################################################
LABEL "com.github.actions.name"="Modular Pipeline"
LABEL "com.github.actions.description"="Container for the modular pipeline execution."
LABEL "com.github.actions.icon"="gear"
LABEL "com.github.actions.color"="red"

############################################################
# Configuration
############################################################
ENV VERSION "0.0.1"

############################################################
# Entrypoint
############################################################
COPY actions/* /usr/local/bin/

############################################################
# Installation
############################################################

RUN echo "System Packages ..." &&\
    apk add --no-cache curl bash &&\
    echo "Tools ..." &&\
    echo "-> Normalize.CI ..." &&\
    curl -L -o /usr/local/bin/normalizeci https://www.philippheuer.me/linux_amd64 &&\
    echo "File Permissions ..." &&\
    chmod +x /usr/local/bin/*

############################################################
# Execution
############################################################
ENTRYPOINT ["/bin/bash"]
CMD []
