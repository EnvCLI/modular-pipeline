##
# Base:
# * alpine
# * openjdk11
#
# Features:
# * unprivileged execution
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

# Build Args
ARG BASE_IMAGE

# Base Image
FROM ${BASE_IMAGE:-adoptopenjdk/openjdk11:x86_64-alpine-jre-11.0.5_10}

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

# Execution
CMD "java" \
  "-Djava.security.egd=file:/dev/./urandom" \
  "-Djava.net.useSystemProxies=true" \
  "-Duser.language=${JVM_USER_LANGUAGE:-en}" \
  "-Duser.country=${JVM_USER_COUNTRY:-US}" \
  "-Duser.timezone=${JVM_USER_TIMEZONE:-UTC}" \
  "-Dorg.jboss.logging.provider=log4j2" \
  "-Dfile.encoding=${JVM_FILE_ENCODING:-UTF8}" \
  "${JAVA_OPTS_CUSTOM:--Dhello=world}" \
  "-XX:-TieredCompilation" \
  "-XX:+UseStringDeduplication" \
  "-XX:+UseG1GC" \
  "-XX:OnOutOfMemoryError=\"kill -TERM $p; sleep 10; kill -9 %p\"" \
  "-jar" \
  "/app.jar"
