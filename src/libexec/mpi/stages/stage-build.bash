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
    @mpi action container-build
    exit 0
  fi

  # golang
  if [[ ${PROJECT_TYPE} =~ ^golang$ ]]; then
    @mpi action go-build
    exit 0
  fi

  # hugo
  if [[ ${PROJECT_TYPE} =~ ^hugo$ ]]; then
    @mpi action hugo-build
    exit 0
  fi

  # java
  if [[ ${PROJECT_TYPE} =~ ^java$ ]]; then
    @mpi action java-build
    exit 0
  fi

  # python
  if [[ ${PROJECT_TYPE} =~ ^python$ ]]; then
    @mpi action python-build
    exit 0
  fi

  # revealjs
  if [[ ${PROJECT_TYPE} =~ ^revealjs$ ]]; then
    @mpi action revealjs-build
    exit 0
  fi

  # no match
  @mpi.log_message "WARN" "project type [${PROJECT_TYPE}] is not supported!"
}

# entrypoint
main "$@"
