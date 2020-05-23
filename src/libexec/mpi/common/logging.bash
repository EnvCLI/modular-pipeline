#!/usr/bin/env bash

# Public: Print a log message
#
# Prints a log message if the loglevel is higher or equal to SCRIPT_LOG_LEVEL.
# Valid loglevels are:
# - TRACE
# - DEBUG
# - INFO
# - WARN
# - ERROR
#
# log_priority - The loglevel
# log_message - The message
#
# Examples
#
#   @mpi.log_message "INFO" "Hello World"
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.log_message() {
  declare -A log_levels=([TRACE]=0 [DEBUG]=1 [INFO]=2 [WARN]=3 [ERROR]=4)
  declare log_priority="$1" log_message="$2"

  # check if level exists
  [[ ${log_levels[$log_priority]} ]] || return 1

  # check if level is enough
  (( ${log_levels[$log_priority]} < ${log_levels[${SCRIPT_LOG_LEVEL:-INFO}]} )) && return 0

  # log the message
  >&2 echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${log_priority} : ${log_message}"

  return 0
}
