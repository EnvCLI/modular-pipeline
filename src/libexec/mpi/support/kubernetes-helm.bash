#!/usr/bin/env bash
set -euo pipefail

# make sure the repository is present and usable
@mpi.helm.ensure_chart_repository() {
  local chartWithRepository=${1:-}

  # get chart repo info
  repoName=$(echo $chartWithRepository | cut -d '/' -f 1)
  repoUrl=$(cat "$MPI_RESOURCE_PATH/helm/repos.yaml" | grep -A 1 "name: $repoName" | grep "url:" | awk -F": " '{print $2}')

  # add repository if not present
  set +e
  @mpi.container_command helm repo list --output yaml | grep "name: $repoName"
  local repoListStatus=$?
  set -e
  if [ "$repoListStatus" -ne "0" ]; then
    @mpi.log_message "INFO" "Adding repository [$repoName] with endpoint [$repoUrl]"
    @mpi.container_command helm repo add "$repoName" "$repoUrl"
    return 1
  fi

  # update repositories
  @mpi.container_command helm repo update
}

# download_chart
@mpi.helm.download_chart() {
  local CHART_ID=${1:-} DEPLOYMENT_CHART_VERSION=${2:-} CHART_TARGET_DIR=${3:-}

  # make sure the repository is present and usable
  @mpi.helm.ensure_chart_repository "$CHART_ID"

  # download chart and extract into target dir
  @mpi.log_message "DEBUG" "pulling chart and saving to ${CHART_TARGET_DIR}"
  if [[ -n $DEPLOYMENT_CHART_VERSION ]]; then
    @mpi.container_command helm pull "$CHART_ID" --version "${DEPLOYMENT_CHART_VERSION}" --untar --destination "$CHART_TARGET_DIR"
  else
    @mpi.container_command helm pull "$CHART_ID" --untar --destination "$CHART_TARGET_DIR"
  fi
}
