#!/usr/bin/env bash
set -euo pipefail

# make sure the namespace / project exists - try to create it otherwise
@mpi.kubernetes.ensure_namespace() {
  local TARGET_NAMESPACE=${1:-}
  if [ -z "$TARGET_NAMESPACE" ]; then
    @mpi.log_message "ERROR" "no target namespace specified as first argument"
    exit 1
  fi

  @mpi.log_message "DEBUG" "making sure namespace $TARGET_NAMESPACE exists ..."
  set +e
  @mpi.container_command kubectl get namespace "$TARGET_NAMESPACE" >> /dev/null
  local getNamespaceStatus=$?
  set -e
  if [ "$getNamespaceStatus" -ne "0" ]; then
    ## create namespace
    @mpi.log_message "INFO" "creating namespace $TARGET_NAMESPACE"
    @mpi.container_command kubectl create namespace "$TARGET_NAMESPACE"
  else
    @mpi.log_message "DEBUG" "namespace exists. skipping creation ..."
  fi
}

# download_chart
@mpi.kubernetes.download_chart() {
  local CHART_ID=${1:-}

  # prepare helm cli
  @mpi.log_message "DEBUG" "Initializing Helm ..."
  @mpi.container_command helm init --client-only --skip-refresh &> /dev/null

  # print variable content
  local CHART_REPOSITORY=$(echo $CHART_ID | cut -d '/' -f 1)

  # Check if the repository is known / needs to be added for the deployment to work
  @mpi.log_message "DEBUG" "Chart Repository: ${CHART_REPOSITORY}"
  if [ "$CHART_REPOSITORY" != "stable" ]; then
    ## if the repo isn't stable/ then we're using a custom repository that we need to initialize
    @mpi.log_message "DEBUG" "Using custom chart repository: ${CHART_REPOSITORY}"

    if [ "$CHART_REPOSITORY" == "incubator" ]; then
      @mpi.container_command helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com &> /dev/null
    elif [ "$CHART_REPOSITORY" == "rancher-stable" ]; then
      @mpi.container_command helm repo add rancher-stable https://releases.rancher.com/server-charts/stable &> /dev/null
    elif [ "$CHART_REPOSITORY" == "appscode" ]; then
      @mpi.container_command helm repo add appscode https://charts.appscode.com/stable &> /dev/null
    elif [ "$CHART_REPOSITORY" == "gitlab" ]; then
      @mpi.container_command helm repo add gitlab https://charts.gitlab.io &> /dev/null
    elif [ "$CHART_REPOSITORY" == "jetstack" ]; then
      @mpi.container_command helm repo add jetstack https://charts.jetstack.io &> /dev/null
    elif [ "$CHART_REPOSITORY" == "philippheuer" ]; then
      @mpi.container_command helm repo add philippheuer https://philippheuer.gitlab.io/kubernetes-charts &> /dev/null
    fi
  fi
  @mpi.container_command helm repo update &> /dev/null
}

# initialize tiller
@mpi.kubernetes.initialize_tiller() {
  # check if tiller was already initialized
  set +e
  @mpi.container_command kubectl get serviceaccount --namespace ${DEPLOYMENT_NAMESPACE} tiller >> /dev/null
  local getTillerServiceAccountStatus=$?
  set -e
  if [ "$getTillerServiceAccountStatus" -ne "0" ]; then
    @mpi.log_message "DEBUG" "Service account missing, creating tiller service account ..."

    ## Service Account
    @mpi.container_command kubectl create serviceaccount --namespace ${DEPLOYMENT_NAMESPACE} tiller

    ## Service Account Permissions (namespace admin or cluster admin, depending on $DEPLOYMENT_CLUSTER_ADMIN)
    if [ "$DEPLOYMENT_CLUSTER_ADMIN" == "true" ]; then
      @mpi.log_message "INFO" "Granting tiller cluster admin role."
      @mpi.container_command kubectl create clusterrolebinding ${DEPLOYMENT_NAMESPACE}-tiller-rule \
        --clusterrole=cluster-admin \
        --serviceaccount=${DEPLOYMENT_NAMESPACE}:tiller
    else
      @mpi.log_message "INFO" "Granting tiller namespace admin role."
      @mpi.container_command kubectl create rolebinding ${DEPLOYMENT_NAMESPACE}-tiller-binding \
        --namespace=${DEPLOYMENT_NAMESPACE} \
        --clusterrole=admin \
        --serviceaccount=${DEPLOYMENT_NAMESPACE}:tiller
    fi

    ## Install Tiller
    @mpi.container_command helm init \
      --tiller-namespace "${DEPLOYMENT_NAMESPACE}" \
      --service-account tiller \
      --history-max 3 \
      --upgrade \
      --wait >> /dev/null
    #--override 'spec.template.spec.containers[0].command'='{/tiller,--storage=secret}' \
  else
    @mpi.log_message "DEBUG" "Tiller is initialized. skipping setup ..."
  fi
}
