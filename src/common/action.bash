#!/usr/bin/env bash
set -euo pipefail

# Public: Prepares the environment for pipeline execution by setting default values and creating required directories
#
# Examples
#
#   @mpi.prepare_environment
#
# Returns the exit code of the last command executed or 0 otherwise
@mpi.prepare_environment() {
  # source in .ci/env
  if [ -f ".ci/env" ]; then
    @mpi.log_message "DEBUG" "loading environment from .ci/env"
    export $(grep -v '^#' .ci/env | xargs)
  fi

  # prerequisites
  @mpi.detect_environment
  @mpi.prerequisites_docker
  @mpi.prerequisites_envcli

  # normalizeci
  @mpi.normalizeci

  # ensure required variables are set
  export PROJECT_TYPE=${PROJECT_TYPE:-none}
  export DEPLOYMENT_TYPE=${DEPLOYMENT_TYPE:-none}

  # global properties
  export ARTIFACT_DIR=${ARTIFACT_DIR:-dist}
  export ARTIFACT_BUILD_ARCHS=${ARTIFACT_BUILD_ARCHS:-linux_amd64}
  export TMP_DIR=${TMP_DIR:-tmp}
  mkdir -p "$ARTIFACT_DIR" "$TMP_DIR"
  export SAMPLE_DIR=${SAMPLE_DIR:-samples}

  # container properties
  export CONTAINER_REPO="${CONTAINER_REPO:-$NCI_CONTAINERREGISTRY_REPOSITORY}"
  export CONTAINER_TAG="${CONTAINER_TAG:-$NCI_COMMIT_REF_RELEASE}"

  # proxy
  export HTTP_PROXY=${HTTP_PROXY:-}
  export HTTPS_PROXY=${HTTPS_PROXY:-}
  export PROXY_HOST=${PROXY_HOST:-}
  export PROXY_PORT=${PROXY_PORT:-}
  export JAVA_PROXY_OPTS="-Dhttp.proxyHost=$PROXY_HOST -Dhttp.proxyPort=$PROXY_PORT -Dhttps.proxyHost=$PROXY_HOST -Dhttps.proxyPort=$PROXY_PORT"
}
