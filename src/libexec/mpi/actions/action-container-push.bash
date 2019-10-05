#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # login to registry
  @mpi.container.registry_login "$NCI_CONTAINERREGISTRY_HOST" "$NCI_CONTAINERREGISTRY_USERNAME" "$NCI_CONTAINERREGISTRY_PASSWORD"

  # push image
  @mpi.container.registry_push "${CONTAINER_REPO}:${CONTAINER_TAG}"
}

# entrypoint
main "$@"
