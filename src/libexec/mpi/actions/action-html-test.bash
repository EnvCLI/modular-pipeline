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
  # get dependencies
  @mpi.container_command htmlproofer "$ARTIFACT_DIR" --allow-hash-href --check-html --empty-alt-ignore --disable-external
}

# entrypoint
main "$@"
