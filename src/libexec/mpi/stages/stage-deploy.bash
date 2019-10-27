#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Environment:
#  none
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  @mpi.log_message "INFO" "DEPLOYMENT_TYPE: [${DEPLOYMENT_TYPE}]"
  @mpi.log_message "INFO" "DEPLOYMENT_VARIANT: [${DEPLOYMENT_VARIANT}]"

  # deployment target: none
  if [[ ${DEPLOYMENT_TYPE} == "none" ]]; then
    @mpi.log_message "INFO" "not running deployment, no DEPLOYMENT_TYPE set!"
    exit 0
  fi

  # deployment namespace
  local DEPLOYMENT_NAMESPACE=${1:-$DEPLOYMENT_NAMESPACE}
  if [ -z "$DEPLOYMENT_NAMESPACE" ]; then
    @mpi.log_message "ERROR" "no target environment specified when calling deploy stage!"
    exit 1
  fi

  # deployment id
  local DEPLOYMENT_ID=${2:-$DEPLOYMENT_ID}

  # deployment target
  local DEPLOYMENT_ENVIRONMENT=${3:-$DEPLOYMENT_ENVIRONMENT}
  if [ -z "$DEPLOYMENT_ENVIRONMENT" ]; then
    @mpi.log_message "ERROR" "no target environment specified when calling deploy stage!"
    exit 1
  fi

  @mpi.log_message "INFO" "TARGET NAMESPACE: [${DEPLOYMENT_NAMESPACE}]"
  @mpi.log_message "INFO" "TARGET ID: [${DEPLOYMENT_ID}]"
  @mpi.log_message "INFO" "TARGET ENVIRONMENT: [${DEPLOYMENT_ENVIRONMENT}]"

  # deploymentType: docker swarm
  if echo "${DEPLOYMENT_TYPE}" | grep -q 'swarm'; then
    # web based services
    if echo "${DEPLOYMENT_VARIANT}" | grep -q 'http'; then
      export SWARMSTACK_RESOURCE="${SWARMSTACK_RESOURCE:-swarm-http.yml}"
    fi

    # run deployment
    @mpi action swarm-deploy "$DEPLOYMENT_NAMESPACE" "$DEPLOYMENT_ENVIRONMENT" "$DEPLOYMENT_ID"
    exit 0
  fi

  # deploymentType: helm
  if echo "${DEPLOYMENT_TYPE}" | grep -q 'helm'; then
    export DEPLOYMENT_CHART="${DEPLOYMENT_CHART:-}"

    # web based services
    if echo "${DEPLOYMENT_VARIANT}" | grep -q 'http'; then
      export DEPLOYMENT_CHART="${DEPLOYMENT_CHART:-philippheuer/webservice}"
    fi

    @mpi action helm-deploy "$DEPLOYMENT_NAMESPACE" "$DEPLOYMENT_ENVIRONMENT" "$DEPLOYMENT_ID" "$DEPLOYMENT_CHART"
    exit 0
  fi

  # no match
  @mpi.log_message "ERROR" "deployment type [${DEPLOYMENT_TYPE}] is not supported!"
  exit 1
}

# entrypoint
main "$@"
