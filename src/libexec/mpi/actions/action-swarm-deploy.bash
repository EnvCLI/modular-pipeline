#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Environment:
#  DEPLOYMENT_NAMESPACE: the namespace of the deployment
#  DEPLOYMENT_ID: unique deployment id
#  DEPLOYMENT_ENVIRONMENT: name of the environment (as slug, ie. production, development, ...)
#  SWARMSTACK_FILE: provide a custom file with a docker swarm stack definition. (defaults to swarm.yml)
#
# The output follows the TAP format and can easily be parsed and processed.
function main()
{
  # namespace
  local DEPLOYMENT_NAMESPACE=${1:-$DEPLOYMENT_NAMESPACE}
  if [ -z "$DEPLOYMENT_NAMESPACE" ]; then
    @mpi.log_message "ERROR" "Required attribute DEPLOYMENT_NAMESPACE missing, set via env or pass it as 1st parameter to action-swarm-deploy!"
    exit 1
  fi

  # deployment id
  local DEPLOYMENT_ID=${2:-$DEPLOYMENT_ID}
  if [ -z "$DEPLOYMENT_ID" ]; then
    @mpi.log_message "ERROR" "Required attribute DEPLOYMENT_ID missing, set via env or pass it as 2nd parameter to action-swarm-deploy!"
    exit 1
  fi

  # environment
  local DEPLOYMENT_ENVIRONMENT=${3:-$DEPLOYMENT_ENVIRONMENT}
  if [ -z "$DEPLOYMENT_ENVIRONMENT" ]; then
    @mpi.log_message "ERROR" "Required attribute DEPLOYMENT_ENVIRONMENT missing, set via env or pass it as 3rd parameter to action-swarm-deploy!"
    exit 1
  fi

  @mpi.log_message "INFO" "deploying environment [$DEPLOYMENT_ENVIRONMENT - ID: $DEPLOYMENT_ID] ..."
  # configuration
  export SWARMSTACKFILE=${SWARMSTACKFILE:-swarm.yml}
  export SWARMSTACK_ENV_FILE="deploy.env"

  # support for SWARMSTACKFILE_DEFAULT
  if ! test -f "$SWARMSTACKFILE"; then
    @mpi.log_message "DEBUG" "no swarmstack file provided at [$SWARMSTACKFILE]"

    if [ -z "$SWARMSTACKFILE_DEFAULT" ]; then
      @mpi.log_message "ERROR" "no swarmstack file provided at [$SWARMSTACKFILE] and no default set using SWARMSTACKFILE_DEFAULT!"
      exit 1
    else
      @mpi.log_message "INFO" "using default swarmstack file provided at [$SWARMSTACKFILE] from [$SWARMSTACKFILE_DEFAULT]!"
      curl -L -s -o "${TMP_DIR}/swarm.yml" "$SWARMSTACKFILE_DEFAULT"
      USED_DEFAULT_SWARMCONFIG=true
    fi
  else
    cp $SWARMSTACKFILE "${TMP_DIR}/swarm.yml"
  fi

  # generate deployment configuration
  @mpi.deployment.generate_configuration "$DEPLOYMENT_ENVIRONMENT"

  # container registry login (swarm passes the current registry auth to pull the image if present)
  if [[ -n "$NCI_CONTAINERREGISTRY_HOST" ]]; then
    @mpi.container.registry_login "$NCI_CONTAINERREGISTRY_HOST" "$NCI_CONTAINERREGISTRY_USERNAME" "$NCI_CONTAINERREGISTRY_PASSWORD"
  fi

  # print deployment yml
  @mpi.log_message "DEBUG" "rendered swarm yml: [$(envsubst < ${TMP_DIR}/swarm.yml)]"

  # deploy stack (placeholders are replaced by the .env file provided to the stack file)
  set +e
  @mpi.run_command docker stack deploy --compose-file "${TMP_DIR}/swarm.yml" --with-registry-auth "${DEPLOYMENT_NAMESPACE}_${DEPLOYMENT_ID}"
  deploymentResult=$?
  set -e
  if [ "$deploymentResult" -ne "0" ]; then
    @mpi.log_message "ERROR" "Failed to run deployment!"
    exit $deploymentResult
  else
    @mpi.log_message "INFO" "Deployment executed succesfully!"
  fi
}

# entrypoint
main "$@"
