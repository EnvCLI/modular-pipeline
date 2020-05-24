#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # kind: documentation
  documentationType="${DOCUMENTATION_TYPE:-none}"
  # - hugo
  if [ "${documentationType}" == "hugo" ]; then
    HUGO_TARGET=${HUGO_TARGET:-${ARTIFACT_DIR}/docs}
    @mpi action hugo-build
  # - default
  else
    @mpi.log_message "INFO" "not generating a documentation, type [${documentationType}] is not supported!"
  fi
}

# entrypoint
main "$@"
