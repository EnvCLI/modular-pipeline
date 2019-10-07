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
  local DEPLOYMENT_ENVIRONMENT=${DEPLOYMENT_ENVIRONMENT:-none}

  @mpi stage prepare
  @mpi stage build
  @mpi stage test
  @mpi stage package
  @mpi stage audit
  @mpi stage publish
  @mpi stage deploy $DEPLOYMENT_ENVIRONMENT
  @mpi stage performance
  @mpi stage cleanup
}

# entrypoint
main "$@"
