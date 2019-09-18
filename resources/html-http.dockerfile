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

# base image
FROM docker.io/nginxinc/nginx-unprivileged:1.16-alpine

############################################################
# Installation
############################################################

# dependencies
USER root
RUN apk add --no-cache curl
USER 101

# copy files from rootfs to the container
ADD dist/* /usr/share/nginx/html/

############################################################
# Execution
############################################################

# expose
EXPOSE 8080/tcp

# execution
