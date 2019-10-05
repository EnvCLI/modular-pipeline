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
  # hugo
  if [[ ${DOCUMENTATION_TYPE} =~ ^hugo$ ]]; then
    @mpi action hugo-build
    exit 0
  fi

  # no match
  @mpi.log_message "WARN" "project type ${DOCUMENTATION_TYPE} is not supported!"
}

# entrypoint
main "$@"
