############################################################
# Base Image
############################################################

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
# HEALTHCHECK --interval=1m30s --timeout=10s CMD echo -e "GET / HTTP/1.1\n\n" | nc localhost 8080 || exit 1

# Execution
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-XX:-TieredCompilation", "-XX:+UseStringDeduplication", "-XX:+UseG1GC", "-jar", "/app.jar" ]
