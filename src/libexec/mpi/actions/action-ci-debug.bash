#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Environment:
#   *none*
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # arguments
  @mpi.log_message "INFO" "Arguments $@"

  # usable env variables
  @mpi.log_message "INFO" "Available environment variables"
  printenv | grep NCI
}

# entrypoint
main "$@"
