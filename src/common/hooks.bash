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
  if test -f "${hookFile}"; then
    "${hookFile}"
    return 0
  fi

  return 1
}
