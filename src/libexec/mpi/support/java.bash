#!/usr/bin/env bash
set -euo pipefail

# Public: Detect java build system
#
# This will set BUILD_SYSTEM to a build system or unknown of nothing was found.
#
# Examples
#
#   @mpi.java.detect_build_system
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.java.detect_build_system()
{
  if test -f "build.gradle"; then
    @mpi.log_message "DEBUG" "Found a gradle project."
    export BUILD_SYSTEM=gradle
  elif test -f "pom.xml"; then
    @mpi.log_message "DEBUG" "Found a maven project."
    export BUILD_SYSTEM=maven
  else
    @mpi.log_message "WARN" "Could not detect java build system, please use either gradle or maven!"
    export BUILD_SYSTEM=unknown
    exit 1
  fi
}

# function: gradle
@mpi.java.gradle()
{
  GRADLE_CALL=("-Dorg.gradle.appname=gradlew" "-classpath" "gradle/wrapper/gradle-wrapper.jar" "org.gradle.wrapper.GradleWrapperMain")

  # gradle wrapper
  if test -f "gradlew"; then
    # - make sure the gradle wrapper is present and executable.
    if test -f "gradle/wrapper/gradle-wrapper.jar"; then
      chmod +x gradle/wrapper/gradle-wrapper.jar
    fi

    # run build (This essentially downloads a copy of Gradle to build the project with.)
    @mpi.container_command java $JAVA_PROXY_OPTS ${GRADLE_CALL[@]} $@
  else
    @mpi.log_message "ERROR" "Gradle projects require the gradle wrapper to be commited into the repository! Check out https://docs.gradle.org/current/userguide/gradle_wrapper.html"
    exit 1
  fi
}

# function: maven
@mpi.java.mvn()
{
  # maven config
  M2_HOME=${M2_HOME:-/root/.m2}
  MAVEN_CONFIG=${MAVEN_CONFIG:-}
  MAVEN_DEFAULTVERSION=${MAVEN_DEFAULTVERSION:-3.6.2}

  # maven wrapper
  if ! test -f "mvnw"; then
    @mpi.log_message "WARN" "Maven projects should have the maven wrapper commited into the repository! Check out https://www.baeldung.com/maven-wrapper"
  fi

  MAVEN_CALL=("-Dmaven.home=${M2_HOME}" "-Dmaven.multiModuleProjectDirectory=/project" "-classpath" ".mvn/wrapper/maven-wrapper.jar" "org.apache.maven.wrapper.MavenWrapperMain")

  # - make sure the maven wrapper is present
  if test -f ".mvn/wrapper/maven-wrapper.jar"; then
    @mpi.log_message "DEBUG" "Maven wrapper .mvn/wrapper/maven-wrapper.jar is already present."
  else
    @mpi.log_message "INFO" "Couldn't find .mvn/wrapper/maven-wrapper.jar, downloading it ..."
    mkdir -p .mvn/wrapper
    curl -L -s -o .mvn/wrapper/maven-wrapper.jar https://repo.maven.apache.org/maven2/io/takari/maven-wrapper/0.5.6/maven-wrapper-0.5.6.jar
  fi

  # - check for maven wrapper properties file
  if test -f ".mvn/wrapper/maven-wrapper.properties"; then
    @mpi.log_message "DEBUG" "Maven wrapper configuration .mvn/wrapper/maven-wrapper.properties found."
  else
    @mpi.log_message "WARN" "Couldn't find .mvn/wrapper/maven-wrapper.properties, using maven $MAVEN_DEFAULTVERSION as default!"
    echo "distributionUrl=https://repo1.maven.org/maven2/org/apache/maven/apache-maven/$MAVEN_DEFAULTVERSION/apache-maven-$MAVEN_DEFAULTVERSION-bin.zip" >> .mvn/wrapper/maven-wrapper.properties
  fi

  # run build
  @mpi.container_command java $JAVA_PROXY_OPTS ${MAVEN_CALL[@]} $MAVEN_CONFIG $@
}
