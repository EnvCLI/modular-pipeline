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
  @mpi.log_message "TRACE" "Command $*"
  eval "$@"
  return $?
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
  @mpi.run_command "envcli" "run" "$@"
  return $?
}
