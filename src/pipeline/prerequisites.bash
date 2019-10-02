#!/usr/bin/env bash

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
