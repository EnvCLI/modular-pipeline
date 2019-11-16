#!/usr/bin/env bash
set -euo pipefail

# make sure the namespace / project exists - try to create it otherwise
@mpi.kubernetes.ensure_namespace() {
  local TARGET_NAMESPACE=${1:-}
  if [ -z "$TARGET_NAMESPACE" ]; then
    @mpi.log_message "ERROR" "no target namespace specified as first argument!"
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

# default registry access
@mpi.kubernetes.setup_registry_access() {
  local TARGET_NAMESPACE=${1:-}
  if [ -z "$TARGET_NAMESPACE" ]; then
    @mpi.log_message "ERROR" "no target namespace specified as first argument!"
    return 1
  fi

  # check if all required properties are present, do not create registry secret otherwise
  if [ -z "$NCI_CONTAINERREGISTRY_HOST" ] || [ -z "$NCI_CONTAINERREGISTRY_USERNAME" ] || [ -z "$NCI_CONTAINERREGISTRY_PASSWORD" ]; then
    @mpi.log_message "INFO" "not provided registry host / username / password - not creating secret for registry access!"
    return 0
  fi

  # secret
  registrySecretName="${NCI_CONTAINERREGISTRY_HOST//./-}"

  # create image pull secret
  @mpi.container_command kubectl create secret docker-registry "$registrySecretName" \
    --namespace="${TARGET_NAMESPACE}" \
    --docker-server="$NCI_CONTAINERREGISTRY_HOST" \
    --docker-username="$NCI_CONTAINERREGISTRY_USERNAME" \
    --docker-password="$NCI_CONTAINERREGISTRY_PASSWORD" \
    --docker-email="${NCI_CONTAINERREGISTRY_USERNAME}@$NCI_CONTAINERREGISTRY_HOST"

  # set as default image pull secret
  @mpi.container_command kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "$registrySecretName"}]}' \
    --namespace="${TARGET_NAMESPACE}"
}
