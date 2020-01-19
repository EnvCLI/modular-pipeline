#!/usr/bin/env bash
set -euo pipefail

# Documentation
# Function: Java Publish
# Description:
#  This calls the respective publish methods to use the existing maven/gradle plugins to publish into the repositories.
#  those plugins have to be included into your projects manually though.
#
# Variants
#
# - Nexus Repository
#   NEXUS_ADDRESS - Nexus Repository Server
#   NEXUS_USERNAME - Nexus Username
#   NEXUS_PASSWORD - Nexus Password
#
# - Bintray
#   TODO
#
# - Artifactory
#   TODO

# Main Function
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  declare publishType="${1:-$NCI_COMMIT_REF_RELEASE}" version="${2:-$NCI_COMMIT_REF_RELEASE}"

  # detect build system
  @mpi.java.detect_build_system

  # publishType: nexus
  if [ "$publishType" == "nexus" ]; then
    declare repoAddr="${3:-$NEXUS_ADDRESS}" repoUser="${4:-$NEXUS_USERNAME}" repoPass="${5:-$NEXUS_PASSWORD}"
    @mpi.log_message "INFO" "publishing version [$version] at [$repoAddr]."
    @mpi.log_message "DEBUG" "using repository $repoAddr as user $repoUser"

    # publish
    if [ "$BUILD_SYSTEM" == "gradle" ]; then
      # gradle projects require the maven plugin to use uploadArchives
      @mpi.java.gradle uploadArchives -PrepoAddress="$repoAddr" -PrepoUsername="$repoUser" -PrepoPassword="$repoPass" -Pversion="$version"
    else
      @mpi.log_message "ERROR" "$BUILD_SYSTEM does not support publish yet!"
      return 1
    fi
  fi

  # publishType: bintray
  if [ "$publishType" == "bintray" ]; then

    # publish
    if [ "$BUILD_SYSTEM" == "gradle" ]; then
      # requires the bintray plugin
      @mpi.java.gradle bintrayUpload --no-daemon
    else
      @mpi.log_message "ERROR" "$BUILD_SYSTEM does not support publish yet!"
      return 1
    fi
  fi

  # publishType: artifactory
  if [ "$publishType" == "artifactory" ]; then
    # publish
    if [ "$BUILD_SYSTEM" == "gradle" ]; then
      # requires the artifactory plugin
      @mpi.java.gradle artifactoryPublish -Dsnapshot=true --no-daemon
    else
      @mpi.log_message "ERROR" "$BUILD_SYSTEM does not support publish yet!"
      return 1
    fi
  fi
}

# entrypoint
main "$@"
