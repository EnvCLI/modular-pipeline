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
  # package: container
  if [[ ${PACKAGE_TYPE} =~ ^container$ ]]; then
    if [[ ${PROJECT_TYPE} =~ ^java$ ]]; then
      export DOCKERFILE_RESOURCE="java-http.dockerfile"
    elif [[ ${PROJECT_TYPE} =~ ^html$ ]]; then
      export DOCKERFILE_RESOURCE="html-http.dockerfile"
    fi

    @mpi action container-build
    return 0
  fi

  # no match
  @mpi.log_message "WARN" "PACKAGE_TYPE [${PACKAGE_TYPE}] is not supported!"
}

# entrypoint
main "$@"
