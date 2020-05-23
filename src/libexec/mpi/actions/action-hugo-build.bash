#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # configuration
  HUGO_SOURCE=${HUGO_SOURCE:-.}
  HUGO_TARGET=${HUGO_TARGET:-${ARTIFACT_DIR}/hugo}

  # get dependencies
  if test -f "${HUGO_SOURCE}/config.toml"; then
    @mpi.log_message "INFO" "Generating hugo documentation from [${HUGO_SOURCE}], target [${HUGO_TARGET}]!"
    @mpi.container_command hugo --source "${HUGO_SOURCE}" --minify --gc --log --verboseLog

    rm -rf "${HUGO_TARGET}"
    cp -R "${HUGO_SOURCE}/public" "${HUGO_TARGET}"
    rm -rf "${HUGO_SOURCE}/public"
  else
    @mpi.log_message "ERROR" "Hugo needs a config.toml!"
    exit 1
  fi
}

# entrypoint
main "$@"
