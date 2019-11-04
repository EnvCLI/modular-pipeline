#!/usr/bin/env bash

# Public: Checks if a hook with the specified name exists in the current project
#
# Will check the current directory for a file called `.ci/hooks/hookName.sh`.
# The hook directory can be changed by setting `MPI_HOOKS_DIR` to any path.
#
# $1 - The name of the hook to be executed. (pre_build, post_build, ...)
#
# Examples
#
#   @mpi.run_hook "pre-build"
#
# Returns the exit code of the last command executed or 0 otherwise
@mpi.run_hook() {
  declare hookName="$1"

  # overwritable properties
  hookDir=${MPI_HOOKS_DIR:-.ci/hooks}

  # check if file exist and run it
  local hookFile="$hookDir/${hookName}.sh"
  @mpi.log_message "DEBUG" "checking for hook at $hookDir/${hookName}.sh"
  if [ -f "${hookFile}" ]; then
    @mpi.log_message "INFO" "running hook $hookDir/${hookName}.sh"
    "${hookFile}"

    if [ ! $? == "0" ]; then
      @mpi.log_message "ERROR" "execution of hook [$hookDir/${hookName}.sh] failed with code $?!"
      return 1
    fi
  fi

  return 1
}
