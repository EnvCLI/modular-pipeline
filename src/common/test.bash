#!/usr/bin/env bash

# Public: Test Setup Script
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.test_setup() {
  export SCRIPT_LOG_LEVEL=TRACE
}

# Public: Test Teardown Script
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.test_teardown() {
  unset SCRIPT_LOG_LEVEL
}
