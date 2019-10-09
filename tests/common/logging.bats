#!/usr/bin/env bats

# Setup
setup() {
  . ${BATS_CWD}/src/libexec/mpi/mpi-core.bash
  @mpi.test_setup
}

# Teardown
teardown() {
  @mpi.test_teardown
}

# Test Cases
@test "@mpi.log_message - trace" {
  SCRIPT_LOG_LEVEL=TRACE
  run @mpi.log_message "TRACE" "Test Message"

  [[ $status -eq 0 ]]
  [[ ${lines[0]} == *"TRACE : Test Message" ]]
}

@test "@mpi.log_message - debug" {
  SCRIPT_LOG_LEVEL=DEBUG
  run @mpi.log_message "DEBUG" "Test Message"

  [[ $status -eq 0 ]]
  [[ ${lines[0]} == *"DEBUG : Test Message" ]]
}

@test "@mpi.log_message - info" {
  SCRIPT_LOG_LEVEL=INFO
  run @mpi.log_message "INFO" "Test Message"

  [[ $status -eq 0 ]]
  [[ ${lines[0]} == *"INFO : Test Message" ]]
}

@test "@mpi.log_message - warn" {
  SCRIPT_LOG_LEVEL=WARN
  run @mpi.log_message "WARN" "Test Message"

  [[ $status -eq 0 ]]
  [[ ${lines[0]} == *"WARN : Test Message" ]]
}

@test "@mpi.log_message - error" {
  SCRIPT_LOG_LEVEL=ERROR
  run @mpi.log_message "ERROR" "Test Message"

  [[ $status -eq 0 ]]
  [[ ${lines[0]} == *"ERROR : Test Message" ]]
}

@test "@mpi.log_message - test loglevels" {
  export SCRIPT_LOG_LEVEL=ERROR
  run @mpi.log_message "INFO" "Test Message"

  [[ $status -eq 0 ]]
}
