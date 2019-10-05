#! /usr/bin/env bash

# Support enabling a debug mode to print all commands and the results
#
# NOTE:
# ----
# The debug mode can be enabled by setting DEBUG to TRUE.
MPI_DEBUG=${MPI_DEBUG:-false}
if [ "$MPI_DEBUG" == "true" ]; then
  echo "-> Debugging mode enabled ..."
  set -x
fi

# Checking for system requirements
#
# NOTE:
# ----
# This will make sure that at least bash 3.2 or later is available.
if [[ "${BASH_VERSINFO[0]}" -lt '3' ||
    ( "${BASH_VERSINFO[0]}" -eq '3' && "${BASH_VERSINFO[1]}" -lt '2' ) ]]; then
  printf "This module requires bash version 3.2 or greater:\n  %s %s\n" "$BASH" "$BASH_VERSION"
  exit 1
fi

# Set the script root path, so allow loading scripts relative to the main script.
#
# NOTE:
# ----
# The variable will also be exported to make it available to subprocesses (python, golang, etc.) if needed.
export MPI_ROOT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export MPI_TEST_PATH="${MPI_TEST_PATH:-$MPI_ROOT_PATH/tests}"

# Include scripts
#
# NOTE:
# ----
# This will load all required scripts
source "$MPI_ROOT_PATH/common/common.bash"
source "$MPI_ROOT_PATH/pipeline/pipeline.bash"
source "$MPI_ROOT_PATH/action-helper/action-helper.bash"

# Main function
#
# NOTE:
# ----
# This is the main entrypoint of the project.
@mpi() {
  # parameters
  case "${1:-}" in
    action)
      declare actionName="$2" scriptFile="$MPI_ROOT_PATH/actions/action-${2}.bash"
      if [ ! -f "$scriptFile" ]; then
        @mpi.log_message "ERROR" "Action [${actionName}] does not exist!"
        return 1
      fi

      @mpi.log_message "INFO" "Action [${actionName}] started ..."
      local startAt=`date +%s`
      @mpi.prepare_environment
      @mpi.run_hook "pre_${actionName}" || true
      @mpi.run_script "$scriptFile" "${@:3}"
      @mpi.run_hook "post_${actionName}" || true
      local endAt=`date +%s`
      @mpi.log_message "INFO" "Action [${actionName}] completed in [$(expr $endAt - $startAt)] seconds."
      ;;
    stage)
      declare stageName="$2" scriptFile="$MPI_ROOT_PATH/stages/stage-${2}.bash"
      if [ ! -f "$scriptFile" ]; then
        @mpi.log_message "ERROR" "Action [${actionName}] does not exist!"
        return 1
      fi

      @mpi.log_message "INFO" "Stage [${stageName}] started ..."
      local startAt=`date +%s`
      @mpi.prepare_environment
      @mpi.run_hook "pre_${stageName}" || true
      @mpi.run_script "$scriptFile" "${@:3}"
      @mpi.run_hook "post_${stageName}" || true
      local endAt=`date +%s`
      @mpi.log_message "INFO" "Stage [${stageName}] completed in [$(expr $endAt - $startAt)] seconds."
      ;;
    *)
      echo "HELP TEXT"
      ;;
  esac
}
