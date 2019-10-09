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
  # container registry
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

  # bintray
  if [[ ${PUBLISH_TYPE} == "bintray" ]]; then
    # for cli and libraries, TODO: add filter later
    @mpi.log_message "INFO" "publishing bintray artifacts from dist/"
    action-bintray-publish
  fi
}

# entrypoint
main "$@"
