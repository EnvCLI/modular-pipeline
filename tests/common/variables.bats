#!/usr/bin/env bats

# Setup
setup() {
  . ${BATS_CWD}/src/libexec/mpi/mpi-core.bash
  @mpi.test_setup
  SCRIPT_LOG_LEVE=TRACE
}

# Teardown
teardown() {
  @mpi.test_teardown
}

# Test Cases
@test "@mpi.load_env_from_file - variable from file" {
  envFile=$(mktemp)
  echo "TESTVAR=THEVALUE" > "$envFile"
  @mpi.load_env_from_file "$envFile"
  printenv | grep TESTVAR

  [[ $TESTVAR == "THEVALUE" ]]
}

@test "@mpi.load_env_from_file - session.environment" {
  envFile=$(mktemp)
  TESTVAR=ORIGINALVALUE
  echo "TESTVAR=session.environment" > "$envFile"
  @mpi.load_env_from_file "$envFile"
  printenv | grep TESTVAR

  [[ $TESTVAR == "ORIGINALVALUE" ]]
}


