#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # configuration
  MAIN_FILE=${MAIN_FILE:-main.py}

  # compile .py files
  @mpi.container_command python $MAIN_FILE
}

# entrypoint
main "$@"
