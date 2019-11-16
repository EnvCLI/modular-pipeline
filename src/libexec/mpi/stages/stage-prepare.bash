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
  if [[ ${PROJECT_TYPE} =~ ^container$ ]]; then
    @mpi.log_message "INFO" "does not need any preparation."
    return 0
  fi

  # golang
  if [[ ${PROJECT_TYPE} =~ ^golang*$ ]]; then
    @mpi.log_message "INFO" "pulling images ..."
    @mpi.envcli pull-image go upx
    return 0
  fi

  # java
  if [[ ${PROJECT_TYPE} =~ ^java$ ]]; then
    @mpi.log_message "INFO" "pulling images ..."
    @mpi.envcli pull-image java
    return 0
  fi

  # no match
  @mpi.log_message "DEBUG" "project type [${PROJECT_TYPE}] does not support prepare yet!"
}

# entrypoint
main "$@"
