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
  # container
  if [[ ${PROJECT_TYPE} =~ ^container-.*$ ]]; then
    @mpi.log_message "INFO" "does not need any preparation."
    exit 0
  fi

  # container
  if [[ ${PROJECT_TYPE} =~ ^golang-.*$ ]]; then
    @mpi.log_message "INFO" "pulling images ..."
    envcli pull-image go upx
    exit 0
  fi

  # deployment
  if [[ ${PROJECT_TYPE} =~ ^deployment*$ ]]; then
    # check for invalid combinations
    if [[ ${DEPLOYMENT_TYPE} =~ ^none*$ ]]; then
      @mpi.log_message "ERROR" "project type [${PROJECT_TYPE}] is not supported with deployment type [${DEPLOYMENT_TYPE}]!"
      exit 1
    fi
    exit 0
  fi

  # java
  if [[ ${PROJECT_TYPE} =~ ^java-.*$ ]]; then
    @mpi.log_message "INFO" "pulling images ..."
    envcli pull-image java
    exit 0
  fi

  # no match
  @mpi.log_message "DEBUG" "project type [${PROJECT_TYPE}] does not support prepare yet!"
}

# entrypoint
main "$@"
