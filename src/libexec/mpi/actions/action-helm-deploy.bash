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
  HELM_ARGS="${HELM_ARGS:-}"

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

  # prepare helm cli
  @mpi.log_message "DEBUG" "initializing helm ..."
  @mpi.container_command helm init --client-only --skip-refresh &> /dev/null

  # download chart or copy from local path (makes sure chart is in ${TMP_DIR}/helm-deploy-chart)
  @mpi.log_message "DEBUG" "load the helm chart"
  local DEPLOYMENT_CHART=${4:-$DEPLOYMENT_CHART}
  if [ -z "$DEPLOYMENT_CHART_LOCALPATH" ] && [ -z "$DEPLOYMENT_CHART" ]; then
    @mpi.log_message "ERROR" "error: no deployment chart specified! Plase set [DEPLOYMENT_CHART] or [DEPLOYMENT_CHART_LOCALPATH]!"
    exit 1
  fi

  CHART_NAME=$(basename "${DEPLOYMENT_CHART}") # because the dirname needs to be the same as the chartname in v2.x
  if [[ -n $DEPLOYMENT_CHART_LOCALPATH ]]; then
    @mpi.log_message "DEBUG" "copying chart from $DEPLOYMENT_CHART_LOCALPATH"
    CHART_NAME=$(basename "${DEPLOYMENT_CHART_LOCALPATH}")
    @mpi.run_command cp -rf "$DEPLOYMENT_CHART_LOCALPATH" "${TMP_DIR}/helm-deploy-chart/"
  else
    @mpi.log_message "DEBUG" "downloading chart from remote $DEPLOYMENT_CHART"
    CHART_NAME=$(basename "${DEPLOYMENT_CHART}")
    @mpi.kubernetes.download_chart "$DEPLOYMENT_CHART" "${DEPLOYMENT_CHART_VERSION:-}" "${TMP_DIR}/helm-deploy-chart/$CHART_NAME"
  fi

  # make sure the target namespace exists
  @mpi.kubernetes.ensure_namespace "$DEPLOYMENT_NAMESPACE"

  # init tiller
  @mpi.kubernetes.initialize_tiller "$DEPLOYMENT_NAMESPACE"

  # registry access
  @mpi.kubernetes.setup_registry_access "$DEPLOYMENT_NAMESPACE"

  # generate deployment configuration
  @mpi.deployment.generate_configuration "$DEPLOYMENT_ENVIRONMENT"

  # get helm values yaml
  @mpi.get_filepath_or_default "DEPLOYMENT_CHART_VALUES" "helm-values.yml"

  # replace env variables in file
  @mpi.substitute_environment_in_file "$DEPLOYMENT_CHART_VALUES"

  # create configMap (from deploy-config.env)
  configType=${configType:-none}
  if [ -f "${TMP_DIR}/deploy-config.env" ]; then
    @mpi.log_message "INFO" "creating configMap [${DEPLOYMENT_ID}-configmap]"
    @mpi.container_command kubectl create configmap \
      "${DEPLOYMENT_ID}-configmap" \
      --namespace "$DEPLOYMENT_NAMESPACE" \
      --from-env-file="${TMP_DIR}/deploy-config.env" \
      -o yaml --dry-run > "${TMP_DIR}/helm-deploy-config.yaml"
    @mpi.container_command kubectl apply -f "${TMP_DIR}/helm-deploy-config.yaml"
    @mpi.file.safe_remove "${TMP_DIR}/helm-deploy-config.yaml"
    configType=env
  fi

  # create secret (from deploy-secret.env)
  secretType=${secretType:-none}
  if [ -f "${TMP_DIR}/deploy-secret.env" ]; then
    @mpi.log_message "INFO" "creating secret [${DEPLOYMENT_ID}-secret]"
    @mpi.container_command kubectl create secret generic \
      "${DEPLOYMENT_ID}-secret" \
      --namespace "$DEPLOYMENT_NAMESPACE" \
      --from-env-file="${TMP_DIR}/deploy-secret.env" \
      -o yaml --dry-run > "${TMP_DIR}/helm-deploy-secret.yaml"
    @mpi.container_command kubectl apply -f "${TMP_DIR}/helm-deploy-secret.yaml"
    @mpi.file.safe_remove "${TMP_DIR}/helm-deploy-secret.yaml"
    secretType=env
  fi

  # deploy the helm chart
  #
  # * tiller-namespace: the namespace helms service side component tiller runs in
  # * namespace: the target namespace we deploy into
  # * install: install the specified chart, if it is not deployed yet
  # * force: overwrite conflicting resources if required (some have immutable attributes)
  # * version: the version of the chart that should be used
  @mpi.log_message "INFO" "deploying using chart [${DEPLOYMENT_CHART}:${DEPLOYMENT_CHART_VERSION:-latest}] into namespace [$DEPLOYMENT_NAMESPACE] as [$DEPLOYMENT_ID]"
  @mpi.container_command helm upgrade \
    --tiller-namespace "${DEPLOYMENT_NAMESPACE}" \
    --namespace "${DEPLOYMENT_NAMESPACE}" \
    --install \
    --force \
    -f "$DEPLOYMENT_CHART_VALUES" \
    --set "deployment.configType=$configType,deployment.secretType=$secretType" \
    $HELM_ARGS \
    "$DEPLOYMENT_ID" "${TMP_DIR}/helm-deploy-chart/$CHART_NAME"
}

# entrypoint
main "$@"
