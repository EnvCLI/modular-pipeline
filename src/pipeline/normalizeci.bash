#!/usr/bin/env bash
set -euo pipefail

# Public: Prints the stack trace at the point of the call.
#
# If supplied, the `skip_callers` argument should be a positive integer (i.e. 1
# or greater) to remove the caller (and possibly the caller's caller, and so on)
# from the resulting stack trace.
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.normalizeci() {
  # only run if NCI is not set yet
  if [ -z ${NCI+x} ]; then
    @mpi.log_message "TRACE" "normalizing ci variables"
    eval $(envcli run normalizeci)
  fi

  return 0
}
