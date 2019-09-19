##
# Base:
# * alpine
# * nginx
#
# Features:
# * unprivileged execution
#
# Networking:
# * 8080/tcp: HTTP Access
##

############################################################
# Base Image
############################################################

# Build Args
ARG BASE_IMAGE

# Base Image
FROM ${BASE_IMAGE:-docker.io/nginxinc/nginx-unprivileged:1.16-alpine}

############################################################
# Installation
############################################################

# dependencies
USER root
RUN apk add --no-cache curl bash &&\
    curl -L -s -o "/entrypoint.sh" "https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/resources/html-http.entrypoint" &&\
    chmod +x /entrypoint.sh &&\
    chown -R 101:0 /usr/share/nginx/html &&\
    chmod 775 -R /usr/share/nginx/html
USER 101

# copy files from rootfs to the container
ADD dist/* /usr/share/nginx/html/

############################################################
# Execution
############################################################

# working directory
WORKDIR /usr/share/nginx/html

# expose
EXPOSE 8080/tcp

# entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]

# cmd
CMD ["nginx", "-g", "daemon off;"]
