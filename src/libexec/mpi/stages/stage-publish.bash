#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Environment:
#  none
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # publishType: containerregistry
  if [[ ${PUBLISH_TYPE} == "containerregistry" ]]; then
    if test -f "${TMP_DIR}/container-image/main.tar"; then
      # import image
      @mpi.log_message "INFO" "publishing container image from ${TMP_DIR}/container-image/main.tar"
      @mpi.run_command docker load -i "${TMP_DIR}/container-image/main.tar"

      # publish
      @mpi action container-push
    else
      @mpi.log_message "INFO" "can't publish into container registry ..."
      exit 1
    fi
  fi

  # publishType: nexus
  if [[ ${PUBLISH_TYPE} == "nexus" ]]; then
    if [[ ${PROJECT_TYPE} == "java" ]]; then
      @mpi action java-publish
    fi
  fi

  # publishType: bintray
  if [[ ${PUBLISH_TYPE} == "bintray" ]]; then
    if [[ ${PROJECT_TYPE} == "java" ]]; then
      @mpi action java-publish
    fi
  fi

  # publishType: artifactory
  if [[ ${PUBLISH_TYPE} == "artifactory" ]]; then
    if [[ ${PROJECT_TYPE} == "java" ]]; then
      @mpi action java-publish
    fi
  fi

  # github
  if [[ ${PUBLISH_TYPE} == "github" ]]; then
    # create github release

    # upload artifacts

    @mpi.log_message "WARN" "publishType GitHub is not supported yet!"
    return 0
  fi
}

# entrypoint
main "$@"
