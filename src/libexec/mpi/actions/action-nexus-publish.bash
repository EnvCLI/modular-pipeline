#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Parameters
# - VERSION
# - NEXUS_ADDRESS
# - NEXUS_USERNAME
# - NEXUS_PASSWORD
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  declare version="${1:-$NCI_COMMIT_REF_RELEASE}" repoAddr="${2:-$NEXUS_ADDRESS}" repoUser="${3:-$NEXUS_USERNAME}" repoPass="${3:-$NEXUS_PASSWORD}"
  @mpi.log_message "INFO" "publishing version [$version] at [$repoAddr]."
  @mpi.log_message "DEBUG" "using repository $repoAddr as user $repoUser"

  # detect build system
  @mpi.java.detect_build_system

  # publish
  if [ "$BUILD_SYSTEM" == "gradle" ]; then
    # gradle projects require the maven plugin to use uploadArchives
    @mpi.java.gradle uploadArchives -PrepoAddress="$repoAddr" -PrepoUsername="$repoUser" -PrepoPassword="$repoPass" -Pversion="$version"
  else
    @mpi.log_message "ERROR" "$BUILD_SYSTEM does not support publish yet!"
    return 1
  fi
}

# entrypoint
main "${@:2}"
