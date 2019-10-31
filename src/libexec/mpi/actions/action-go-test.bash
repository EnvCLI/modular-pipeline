#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Environment:
#  VERBOSE: Will print additional test information on execution
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # configuration
  VERBOSE=${VERBOSE:-false}

  # run tests
  if echo "$VERBOSE" | grep -q 'true'; then
    @mpi.container_command go test -cover -v ./...
  else
    @mpi.container_command go test -cover ./...
  fi
}

# entrypoint
main "$@"
