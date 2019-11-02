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
    return 0
  fi

  # deployment namespace
  local DEPLOYMENT_NAMESPACE=${1:-$DEPLOYMENT_NAMESPACE}
  if [ -z "$DEPLOYMENT_NAMESPACE" ]; then
    @mpi.log_message "ERROR" "no target environment specified when calling deploy stage!"
    return 1
  fi

  # deployment id
  local DEPLOYMENT_ID=${2:-$DEPLOYMENT_ID}

  # deployment target
  local DEPLOYMENT_ENVIRONMENT=${3:-$DEPLOYMENT_ENVIRONMENT}
  if [ -z "$DEPLOYMENT_ENVIRONMENT" ]; then
    @mpi.log_message "ERROR" "no target environment specified when calling deploy stage!"
    return 1
  fi

  @mpi.log_message "INFO" "TARGET NAMESPACE: [${DEPLOYMENT_NAMESPACE}]"
  @mpi.log_message "INFO" "TARGET ID: [${DEPLOYMENT_ID}]"
  @mpi.log_message "INFO" "TARGET ENVIRONMENT: [${DEPLOYMENT_ENVIRONMENT}]"
  deploymentStatus="FAILURE"

  # deploymentType: docker swarm
  if [ "${DEPLOYMENT_TYPE}" == "swarm" ]; then
    # TYPE: docker swarm

    # web based services
    if echo "${DEPLOYMENT_VARIANT}" | grep -q 'http'; then
      export SWARMSTACK_RESOURCE="${SWARMSTACK_RESOURCE:-swarm/swarm-http.yml}"
    fi

    # run deployment
    @mpi action swarm-deploy "$DEPLOYMENT_NAMESPACE" "$DEPLOYMENT_ENVIRONMENT" "$DEPLOYMENT_ID"
    deploymentStatus="SUCCESS"
  elif [ "${DEPLOYMENT_TYPE}" == "helm" ]; then
    # TYPE: helm charts
    export DEPLOYMENT_CHART="${DEPLOYMENT_CHART:-}"

    # web based services
    if [ "${DEPLOYMENT_VARIANT}" == "http" ]; then
      export DEPLOYMENT_CHART_LOCALPATH="${DEPLOYMENT_CHART_LOCALPATH:-$MPI_RESOURCE_PATH/helm/charts/webservice}"
      export DEPLOYMENT_CHART_VALUES_RESOURCE="${DEPLOYMENT_CHART_VALUES_RESOURCE:-helm/translator/webservice.yaml}"
    fi

    @mpi action helm-deploy "$DEPLOYMENT_NAMESPACE" "$DEPLOYMENT_ENVIRONMENT" "$DEPLOYMENT_ID" "$DEPLOYMENT_CHART"
    deploymentStatus="SUCCESS"
  else
    @mpi.log_message "ERROR" "deployment type [${DEPLOYMENT_TYPE}] is not supported!"
    return 1
  fi
}

# entrypoint
main "$@"
