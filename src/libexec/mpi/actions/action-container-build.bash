#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Environment:
#   DOCKERFILE: Path of the dockerfile. (default ./Dockerfile)
#   DOCKERFILE_RESOURCES: Use the dockerfile out of the provided resources  (if no local dockerfile exists).
#   DOCKERFILE_URL: Get the dockerfile from a remote url (if no local dockerfile exists).
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # configuration
  DOCKERFILE=${DOCKERFILE:-Dockerfile}
  @mpi.get_filepath_or_default "DOCKERFILE" "Dockerfile"

  # parse the dockerfile to find the base image (+split repo / tag)
  @mpi.container.parse_dockerfile_baseimage "$DOCKERFILE"
  @mpi.log_message "DEBUG" "container image - repository: $CONTAINER_BASE_IMAGE_REPOSITORY"
  @mpi.log_message "DEBUG" "container image - tag: $CONTAINER_BASE_IMAGE_TAG"

  # build
  IFS=',' read -r -a artifactBuildArchArray <<< $(echo "$ARTIFACT_BUILD_ARCHS")
  for VALUE in "${artifactBuildArchArray[@]}"; do
    IFS='_' read -r -a row <<< "$VALUE"
    local buildOS="${row[0]}"
    local buildArch="${row[1]}"

    # run build
    @mpi.container.build "$CONTAINER_REPO" "$CONTAINER_TAG" "$CONTAINER_BASE_IMAGE_REPOSITORY" "$CONTAINER_BASE_IMAGE_TAG" "$buildOS" "$buildArch"
  done

  # create manifest
  # create_container_manifest "$CONTAINER_REPO:$CONTAINER_TAG" "$ARTIFACT_BUILD_ARCHS"
}

# entrypoint
main "$@"
