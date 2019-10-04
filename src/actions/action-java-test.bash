#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # detect build system
  @mpi.java.detect_build_system

  # run tests
  if echo "$BUILD_SYSTEM" | grep -q 'gradle'; then
    @mpi.java.gradle test --no-daemon
  elif echo "$BUILD_SYSTEM" | grep -q 'maven'; then
    set +e
    @mpi.java.mvn clean test

    # - print test reports on build failure
    if [ ! $? == "0" ]; then
      find -path '*/target/surefire-reports/*.txt' -exec cat {} \;
      exit 1
    fi
    set -e
  fi
}

# entrypoint
main "$@"
