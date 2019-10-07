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
  # bash
  if [[ ${PROJECT_TYPE} =~ ^shell*$ ]]; then
    @mpi action shell-test
    return 0
  fi

  # container
  if [[ ${PROJECT_TYPE} =~ ^container*$ ]]; then
    @mpi.log_message "WARN" "no tests for containers yet ..."
    return 0
  fi

  # golang
  if [[ ${PROJECT_TYPE} =~ ^golang*$ ]]; then
    @mpi action go-test
    return 0
  fi

  # java
  if [[ ${PROJECT_TYPE} =~ ^java*$ ]]; then
    @mpi action java-test
    return 0
  fi

  # no match
  @mpi.log_message "WARN" "project type ${PROJECT_TYPE} does not support tests yet!"
}

# entrypoint
main "$@"
