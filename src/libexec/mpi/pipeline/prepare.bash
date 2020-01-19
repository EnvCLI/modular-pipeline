#!/usr/bin/env bash
set -euo pipefail

# Public: Checks that docker is present on the system
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.prerequisites_docker() {
  if ! command -v docker > /dev/null; then
    @mpi.log_message "ERROR" "docker is required but missing!"
    exit 1
  fi

  # find container runtime (if docker info fails)
  if ! docker info &>/dev/null; then
    @mpi.log_message "DEBUG" "trying to find a working container runtime as the current one doesn't work ..."

    # set DOCKER_HOST
    set +u
    local CHOST=docker
    local CPORT=2375

    if [ -z "$DOCKER_HOST" ] && [ "$KUBERNETES_PORT" ]; then
      @mpi.log_message "DEBUG" "detected kubernetes usage, using localhost"
      CHOST=localhost
    fi
    if [ "$DOCKER_TLS_CERTDIR" ]; then
      @mpi.log_message "DEBUG" "detected docker tls cert usage, using port 2376"
      CPORT=2376
    fi

    export DOCKER_HOST="tcp://${CHOST}:${CPORT}"
    set -u
  else
    @mpi.log_message "TRACE" "container runtime is ready for use"
  fi

  return 0
}

# Public: Checks that EnvCLI is present on the system
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.prerequisites_envcli() {
  if ! command -v envcli > /dev/null; then
    @mpi.log_message "ERROR" "envcli not available. Please run theinstallation script!"
    exit 1
  fi

  return 0
}

# Public: Calls NormalizeCI to get normalized ci variables
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.normalizeci() {
  # only run if NCI is not set yet
  if [ -z ${NCI+x} ]; then
    @mpi.log_message "TRACE" "normalizing ci variables"
    @mpi.run_command eval $(@mpi.container_command normalizeci)

    if [ -z ${NCI+x} ]; then
      @mpi.log_message "ERROR" "normalized variables not available!"
      exit 1
    fi
  fi

  return 0
}

# Public: Prepares the environment for pipeline execution by setting default values and creating required directories
#
# Examples
#
#   @mpi.prepare_environment
#
# Returns the exit code of the last command executed or 0 otherwise
@mpi.prepare_environment() {
  # make sure this can only be run once, regardless if it was called from a stage/action or sth. else
  export MPI_PREPARE_ENVIRONMENT_RUN=${MPI_PREPARE_ENVIRONMENT_RUN:-false}
  if [[ "$MPI_PREPARE_ENVIRONMENT_RUN" == 'true' ]]; then
    return 0
  fi

  # source in .ci/env
  if [ -f ".ci/env" ]; then
    @mpi.load_env_from_file ".ci/env"
  fi

  # prerequisites
  @mpi.detect_environment
  @mpi.prerequisites_docker
  @mpi.prerequisites_envcli

  # proxy
  export HTTP_PROXY=${HTTP_PROXY:-}
  export HTTPS_PROXY=${HTTPS_PROXY:-}
  export NO_PROXY=${NO_PROXY:-}
  export PROXY_HOST=${PROXY_HOST:-}
  export PROXY_PORT=${PROXY_PORT:-}
  export JAVA_PROXY_OPTS="-Dhttp.proxyHost=$PROXY_HOST -Dhttp.proxyPort=$PROXY_PORT -Dhttps.proxyHost=$PROXY_HOST -Dhttps.proxyPort=$PROXY_PORT"

  # proxy for containers
  envcli config set http-proxy "$HTTP_PROXY"
  envcli config set https-proxy "$HTTPS_PROXY"
  envcli config set no-proxy "$NO_PROXY"

  # normalizeci
  @mpi.normalizeci

  # ensure required variables are set
  export PROJECT_TYPE=${PROJECT_TYPE:-none}
  export PACKAGE_TYPE=${PACKAGE_TYPE:-none}
  export PUBLISH_TYPE=${PUBLISH_TYPE:-none}
  export DEPLOYMENT_TYPE=${DEPLOYMENT_TYPE:-none}
  export DEPLOYMENT_VARIANT=${DEPLOYMENT_VARIANT:-none}

  # global properties
  export ARTIFACT_DIR=${ARTIFACT_DIR:-dist}
  export ARTIFACT_BUILD_ARCHS=${ARTIFACT_BUILD_ARCHS:-linux_amd64}
  export TMP_DIR=${TMP_DIR:-tmp}
  mkdir -p "$ARTIFACT_DIR" "$TMP_DIR"
  export SAMPLE_DIR=${SAMPLE_DIR:-samples}

  # container properties
  export CONTAINER_REPO="${CONTAINER_REPO:-$NCI_CONTAINERREGISTRY_REPOSITORY}"
  export CONTAINER_TAG="${CONTAINER_TAG:-$NCI_COMMIT_REF_RELEASE}"


  # set run to true
  export MPI_PREPARE_ENVIRONMENT_RUN=true
}
