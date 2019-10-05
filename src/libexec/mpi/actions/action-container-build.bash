#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Environment:
#   DOCKERFILE_PATH: Path of the dockerfile, by default the current working directory.
#   DOCKERFILE_NAME: Name of the dockerfile. (default: Dockerfile)
#   DOCKERFILE_URL_DEFAULT: A url to a default dockerfile to use, if the local dockerfile wasn't found/provided.
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # configuration
  DOCKERFILE_PATH="${DOCKERFILE_PATH:-.}"
  DOCKERFILE_NAME="${DOCKERFILE_NAME:-Dockerfile}"
  DOCKERFILE_URL_DEFAULT="${DOCKERFILE_URL_DEFAULT:-}"

  # support for DOCKERFILE_URL_DEFAULT
  if ! test -f "$DOCKERFILE_PATH/$DOCKERFILE_NAME"; then
    @mpi.log_message "DEBUG" "no local dockerfile provided at [$DOCKERFILE_PATH/$DOCKERFILE_NAME]!"

    if [ -z "$DOCKERFILE_DEFAULT" ]; then
      @mpi.log_message "ERROR" "no dockerfile provided at [$DOCKERFILE_PATH/$DOCKERFILE_NAME] and no DOCKERFILE_DEFAULT set!"
      exit 1
    else
      @mpi.log_message "INFO" "using default dockerfile from [$DOCKERFILE_DEFAULT] at [$DOCKERFILE_PATH/$DOCKERFILE_NAME]"
      curl -L -s -o "$DOCKERFILE_PATH/$DOCKERFILE_NAME" "$DOCKERFILE_DEFAULT"
      USED_DEFAULT_DOCKER=true
    fi
  fi

  # parse the dockerfile to find the base image (+split repo / tag)
  @mpi.container.parse_dockerfile_baseimage "$DOCKERFILE_PATH/$DOCKERFILE_NAME"
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

  # remove default dockerfile if used
  if echo "${USED_DEFAULT_DOCKER:-false}" | grep -q 'true'; then
    @mpi.log_message "DEBUG" "removed temporary dockerfile"
    rm "$DOCKERFILE_PATH/$DOCKERFILE_NAME" >> /dev/null
  fi
}

# entrypoint
main "$@"
