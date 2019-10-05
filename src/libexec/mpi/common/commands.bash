#!/usr/bin/env bash

# Public: Runs a command and logs it if the loglevel is lowered
#
# Arguments:
#  any arguments, will be called in `eval`.
#
# Examples
#
#   @mpi.run_command echo "Hello World"
#
# Returns the exit code of the last command executed or 0 otherwise
@mpi.run_command() {
  # quote all args
  allargs=
  for arg in "$@"; do
      arg="${arg//\\/\\\\}"
      allargs="$allargs \"${arg//\"/\\\"}\""
  done

  @mpi.log_message "TRACE" "Command $allargs"
  eval "$allargs"
  return "$?"
}

# Public: Runs a container command
#
# Arguments:
#  binary: will decide which container is used
#  arguments for the binary
#
# Examples
#
#   @mpi.container_command go --version
#
# Returns the exit code of the last command executed or 0 otherwise
@mpi.container_command() {
  @mpi.run_command "envcli" "--config-include=${MPI_ROOT_PATH}/cfg/.envcli.yml" "run" "$@"
  return $?
}
