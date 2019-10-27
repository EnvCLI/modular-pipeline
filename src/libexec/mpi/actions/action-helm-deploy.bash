#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Environment:
#  DEPLOYMENT_ENVIRONMENT: name of the environment (as slug, ie. production, development, ...)
#  DEPLOYMENT_ID: unique deployment id
#  DEPLOYMENT_NAMESPACE: target kubernetes namespace
#  DEPLOYMENT_CLUSTER_ADMIN: deployment needs cluster admin access, defaults to false.
#  DEPLOYMENT_CHART: helm chart.
#  DEPLOYMENT_CHART_VERSION: helm chart version, using latest by default.
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # if debug
  # HELM_ARGS="-debug"
  HELM_ARGS=""

  # parameters
  # - namespaces
  local DEPLOYMENT_NAMESPACE=${1:-$DEPLOYMENT_NAMESPACE}
  if [ -z "$DEPLOYMENT_NAMESPACE" ]; then
    @mpi.log_message "ERROR" "error: no deployment namespace specified! Plase set [DEPLOYMENT_NAMESPACE] or provide it as 1st argument when calling action-helm-deploy!"
    exit 1
  fi
  # - deployment id
  local DEPLOYMENT_ID=${2:-$DEPLOYMENT_ID}
  if [ -z "$DEPLOYMENT_ID" ]; then
    @mpi.log_message "ERROR" "no deployment id specified! Plase set [DEPLOYMENT_ID] or provide it as 2nd argument when calling action-helm-deploy!"
    exit 1
  fi
  # - environment
  local DEPLOYMENT_ENVIRONMENT=${3:-$DEPLOYMENT_ENVIRONMENT}
  if [ -z "$DEPLOYMENT_ENVIRONMENT" ]; then
    @mpi.log_message "ERROR" "no target environment specified. Plase set [DEPLOYMENT_ENVIRONMENT] or provide it as 3rd argument when calling action-helm-deploy!"
    exit 1
  fi
  @mpi.log_message "DEBUG" "deploying environment [$DEPLOYMENT_ENVIRONMENT - ID: $DEPLOYMENT_ID] ..."

  # - access
  export DEPLOYMENT_CLUSTER_ADMIN=${DEPLOYMENT_CLUSTER_ADMIN:-"false"}
  if [[ -z "${KUBECONFIG_CONTENT:-}" ]]; then
    @mpi.log_message "ERROR" "Please encode your kubeconfig as base64 and set it as environment variable [KUBECONFIG_CONTENT] to allow the pipeline to access a k8s cluster!"
    return 1
  fi

  # - chart
  local DEPLOYMENT_CHART=${4:-$DEPLOYMENT_CHART}
  if [ -z "$DEPLOYMENT_CHART" ]; then
    @mpi.log_message "ERROR" "error: no deployment chart specified! Plase set [DEPLOYMENT_CHART] or provide it as 4th argument when calling action-helm-deploy!"
    exit 1
  fi
  local DEPLOYMENT_CHART_VERSION=${DEPLOYMENT_CHART_VERSION:-}

  # make sure the target namespace exists
  @mpi.kubernetes.ensure_namespace "$DEPLOYMENT_NAMESPACE"

  # download the chart / add the required repositories
  @mpi.kubernetes.download_chart "$DEPLOYMENT_CHART"

  # init tiller
  @mpi.kubernetes.initialize_tiller "$DEPLOYMENT_NAMESPACE"

  # registry access
  @mpi.kubernetes.setup_registry_access "$DEPLOYMENT_NAMESPACE"

  # generate deployment configuration
  @mpi.deployment.generate_configuration "$DEPLOYMENT_ENVIRONMENT"

  # deploy the helm chart
  #
  # * tiller-namespace: the namespace helms service side component tiller runs in
  # * namespace: the target namespace we deploy into
  # * install: install the specified chart, if it is not deployed yet
  # * force: overwrite conflicting resources if required (some have immutable attributes)
  # * version: the version of the chart that should be used
  @mpi.log_message "INFO" "deploying using chart [${DEPLOYMENT_CHART}:${DEPLOYMENT_CHART_VERSION:-latest}] into namespace [$DEPLOYMENT_NAMESPACE] as [$DEPLOYMENT_ID]"
  if [ -z "${DEPLOYMENT_CHART_VERSION}" ]; then
    $HELM_ARGS="$HELM_ARGS --version ${DEPLOYMENT_CHART_VERSION}"
  fi
  # TODO: generate a values yaml and use it # -f "${TMP_DIR}/helm-values.yaml" \
  @mpi.container_command helm upgrade \
    --tiller-namespace "${DEPLOYMENT_NAMESPACE}" \
    --namespace "${DEPLOYMENT_NAMESPACE}" \
    --install \
    --force \
    --set "image.repository=$CONTAINER_REPO,image.tag=$CONTAINER_TAG,image.pullSecret=" \
    $HELM_ARGS \
    "$DEPLOYMENT_ID" "${DEPLOYMENT_CHART}"
  fi

}

# entrypoint
main "$@"
