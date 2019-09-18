##
# Base:
# * alpine
# * openjdk11
#
# Features:
# * unprivileged execution
# * healthcheck
# * -Djava.security.egd=file:/dev/./urandom is a faster random number generator
# * -XX:-TieredCompilation disables intermediate compilation tiers (1, 2, 3), so that a method is either interpreted or compiled at the maximum optimization level (C2).
# * -XX:+UseG1GC uses the G1 garbage collector
# * -XX:+UseStringDeduplication needs the G1 garbage collector and reduces memory consumption
# * -XX:OnOutOfMemoryError="kill -TERM $p; sleep 10; kill -9 %p" kills the process when running out of heap space, so it can be restarted by a process scheduler
#
# Networking:
# * 8080/tcp: HTTP Access
##

############################################################
# Base Image
############################################################

# Arguments
ARG HEALTHCHECK_ENDPOINT

# Base Image
FROM adoptopenjdk/openjdk11-openj9:jre-11.0.4_11_openj9-0.15.1-alpine

############################################################
# Installation
############################################################

# Dependencies
RUN apk add --no-cache curl

# Copy files from rootfs to the container (there should only be one in /dist)
ADD dist/*.jar /app.jar

############################################################
# Execution
############################################################

# Expose
EXPOSE 8080/tcp

# Healthcheck
HEALTHCHECK --interval=1m30s --timeout=10s CMD curl --fail http://localhost:8080${HEALTHCHECK_ENDPOINT:-/} || exit 1

# Execution
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-XX:-TieredCompilation", "-XX:+UseStringDeduplication", "-XX:+UseG1GC", "-XX:OnOutOfMemoryError=\"kill -TERM $p; sleep 10; kill -9 %p\"", "-jar", "/app.jar" ]
