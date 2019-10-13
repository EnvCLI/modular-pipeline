#!/usr/bin/env bash
set -euo pipefail

# generates the deployment configuration (.env)
@mpi.deployment.generate_configuration() {
  declare deploymentEnvironment="$1"

  # source in .env configuration properties with defaults
  # - common .env file
  if [ -f ".env" ]; then
    @mpi.load_env_from_file ".env"
  fi
  # - environment-specific .env file
  if [ -f ".env-${deploymentEnvironment}" ]; then
    @mpi.load_env_from_file ".env-${deploymentEnvironment}"
  fi

  # get all available variables (sourced or set)
  compgen -v > ${TMP_DIR}/deployvars.env
  readarray -t ALL_VARIABLES < ${TMP_DIR}/deployvars.env
  rm ${TMP_DIR}/deployvars.env &> /dev/null || true # remove if already present

  # prepare deploylent labels
  # - replicas
  export DEPLOYMENT_REPLICAS=${DEPLOYMENT_REPLICAS:-1}
  # - resource limits
  export RESOURCES_SOFT_CPU=${RESOURCES_SOFT_CPU:-0.10}
  export RESOURCES_HARD_CPU=${RESOURCES_HARD_CPU:-1.00}
  export RESOURCES_SOFT_MEMORY=${RESOURCES_SOFT_MEMORY:-128M}
  export RESOURCES_HARD_MEMORY=${RESOURCES_HARD_MEMORY:-512M}

  # deployment url
  export HTTP_ENDPOINT_DEFAULT="${PROJECT_NAME:-NCI_PROJECT_SLUG}-${deploymentEnvironment}"
  export HTTP_ENDPOINT="${HTTP_ENDPOINT:-$HTTP_ENDPOINT_DEFAULT}"
  export HTTP_ENDPOINT_HOST=$(__get_hostname_from_url "$HTTP_ENDPOINT")
  export HTTP_ENDPOINT_PATH=$(__get_path_from_url "$HTTP_ENDPOINT")
  @mpi.log_message "DEBUG" "exposing http endpopint at [${HTTP_ENDPOINT}]"

  # prepare deployment variables
  rm ${TMP_DIR}/deploy.env &> /dev/null || true # remove if already present
  for KEY in "${ALL_VARIABLES[@]}"; do
    VALUE=${!KEY:-}

    # special cases
    if [[ $KEY == "_" ]]; then
      continue
    fi

    # do not add var if it is not present in MPI_DEPLOY_VARS
    # @see common/variables.bash
    if [[ ! $MPI_DEPLOY_VARS =~ .*"$KEY".* ]]; then
      continue
    fi

    # .env for deployments
    echo "$KEY=$VALUE" >> ${TMP_DIR}/deploy.env
  done
}

# get hostname from url
__get_hostname_from_url() {
  declare url="$1"

  echo $url | sed -e "s/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/"
}

# get path from url
__get_path_from_url() {
  declare url="$1"

  echo $url | grep / | cut -d/ -f4-
}
