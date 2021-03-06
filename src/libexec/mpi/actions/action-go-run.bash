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
  @mpi.container_command go run ./src "$@"
}

# entrypoint
main "$@"
