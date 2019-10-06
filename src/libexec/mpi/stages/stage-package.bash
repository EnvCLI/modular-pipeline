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
  # don't package library projects for any language
  if [[ ${PROJECT_TYPE} =~ ^.*-library$ ]]; then
    @mpi.log_message "INFO" "package can not be called for library projects, since they don't have a runtime environment that needs to be build!"
    return 0
  fi

  # java
  if [[ ${PROJECT_TYPE} =~ ^java-http$ ]]; then
    export DOCKERFILE_RESOURCE="java-http.dockerfile"
    @mpi action container-build
    return 0
  fi

  # hugo
  if [[ ${PROJECT_TYPE} =~ ^hugo-http$ ]]; then
    export DOCKERFILE_RESOURCE="html-http.dockerfile"
    @mpi action container-build
    return 0
  fi

  # no match
  @mpi.log_message "WARN" "project type ${PROJECT_TYPE} is not supported by package yet!"
}

# entrypoint
main "$@"
