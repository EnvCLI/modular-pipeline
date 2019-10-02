#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Environment:
#   HUGO_SOURCE: source directory used to generate hugo sites
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # configuration
  HUGO_SOURCE=${HUGO_SOURCE:-.}
  HUGO_URL=${HUGO_URL:-http://localhost}

  # get dependencies
  if test -f config.toml; then
     @mpi.container_command hugo --source "$HUGO_SOURCE" --destination "$ARTIFACT_DIR" --minify --gc --baseURL "$HUGO_URL"
  else
    @mpi.log_message "ERROR" "Hugo needs a config.toml!"
    exit 1
}

# entrypoint
main "$@"
