#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # detect build system
  @mpi.java.detect_build_system

  # run build
  if [[ $BUILD_SYSTEM == "gradle"]]; then
    # gradle
    @mpi.java.gradle clean assemble --no-daemon -Xlint:deprecation

    # copy artifacts to ARTIFACT_DIR
    cp -R build/libs/*.jar $ARTIFACT_DIR
  elif [[ $BUILD_SYSTEM == "maven"]]; then
    # maven
    # - version
    @mpi.java.mvn versions:set -DnewVersion=$NCI_COMMIT_REF_RELEASE

    # - build
    @mpi.java.mvn clean package -DskipTests=true

    # copy artifacts to ARTIFACT_DIR
    cp -R target/*.jar $ARTIFACT_DIR
  fi
}

# entrypoint
main "$@"
