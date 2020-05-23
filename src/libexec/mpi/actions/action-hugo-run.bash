#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # configuration
  HUGO_SOURCE=${HUGO_SOURCE:-.}

  # get dependencies
  if test -f "${HUGO_SOURCE}/config.toml"; then
    @mpi.log_message "INFO" "Generating hugo documentation from [${HUGO_SOURCE}] and watching directory for changes!"
    @mpi.container_command --port 1313:1313 hugo server --source "${HUGO_SOURCE}" --minify --gc --log --verboseLog --baseUrl "/" --watch
  else
    @mpi.log_message "ERROR" "Hugo needs a config.toml!"
    exit 1
  fi
}

# entrypoint
main "$@"
