#!/usr/bin/env bash
set -euo pipefail

# generates the deployment configuration (.env)
@mpi.deployment.generate_configuration() {
  declare deploymentEnvironment="$1"

  # source in .env configuration properties with defaults
  # - common .env file
  if [ -f ".env" ]; then
    _log_message "loading environment from .env" "INFO"
    export $(grep -v '^#' .env | xargs)
  fi
  # - environment-specific .env file
  if [ -f ".env-${deploymentEnvironment}" ]; then
    _log_message "loading environment from .env-${deploymentEnvironment}" "INFO"
    export $(grep -v '^#' ".env-${deploymentEnvironment}" | xargs)
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
  _log_message "exposing http endpopint at [${HTTP_ENDPOINT}]" "DEBUG"

  # prepare deployment variables
  rm ${TMP_DIR}/deploy.env &> /dev/null || true # remove if already present
  for KEY in "${ALL_VARIABLES[@]}"; do
    VALUE=${!KEY:-}

    # special cases
    if [[ $KEY == "_" ]]; then
        continue
    fi
    # script vars
    if [[ $KEY =~ ^(ALL_VARIABLES|KEY|VALUE|PROJECT_TYPE|DEPLOYMENT_TYPE|DEPLOYMENT_VARIANT|deploymentEnvironment|GIT_DEPTH|GIT_STRATEGY|CONTAINER_REPO|CONTAINER_TAG|MPI_RESOURCES_MIRROR|KUBECONFIG_CONTENT|DISABLE_BUILD|DISABLE_PACKAGE)$ ]]; then
        continue
    fi
    # gitlab variables, for feature flags FF see https://docs.gitlab.com/runner/configuration/feature-flags.html
    if [[ $KEY =~ ^(FF_.*|CI|CI_.*|GITLAB_CI|GITLAB_FEATURES|GIT_SSL_NO_VERIFY|HELM_VERSION|KUBERNETES_VERSION|KUBE_INGRESS_BASE_DOMAIN|VERSION)$ ]]; then
        continue
    fi
    # os vars
    if [[ $KEY =~ ^(PWD|SUDO_COMMAND|LC_.*|FUNCNAME|EPOCHREALTIME|DOCKER_.*|SSH_CLIENT|SSH_CONNECTION|SSH_TTY|LESSCLOSE|WSLENV|WSL_DISTRO_NAME|XDG_DATA_DIRS|COMP_WORDBREAKS|LS_COLORS|PROMPT_COMMAND|XDG_RUNTIME_DIR|PS[0-9]|SHELL|LOGNAME|OPTERR|OPTIND|OSTYPE|PATH|SHELLOPTS|UID|USER|colors|MACHTYPE|MAIL|LESSOPEN|IFS|ID|HOSTTYPE|HOSTNAME|HOME|HIST.*|GROUPS|COLUMNS|DIRSTACK|LANG|LINES|LINENO|PPID|PIPESTATUS|RANDOM|SECONDS|SHLVL|TERM|BASH.*)$ ]]; then
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
