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
  if echo "$BUILD_SYSTEM" | grep -q 'gradle'; then
    # gradle
    @mpi.java.gradle clean assemble --no-daemon

    # copy artifacts to ARTIFACT_DIR
    cp -R build/libs/*.jar $ARTIFACT_DIR
  elif echo "$BUILD_SYSTEM" | grep -q 'maven'; then
    # maven
    # - version
    @mpi.java.mvn versions:set -DnewVersion=$NCI_COMMIT_REF_RELEASE

    # - build
    @mpi.java.mvn clean package

    # copy artifacts to ARTIFACT_DIR
    cp -R target/*.jar $ARTIFACT_DIR
  fi
}

# entrypoint
main "$@"
