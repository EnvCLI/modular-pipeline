#!/usr/bin/env bats

# Setup
setup() {
  . ${BATS_CWD}/src/mpi-core.bash
  @mpi.test_setup
}

# Teardown
teardown() {
  @mpi.test_teardown
}

# Test Cases
@test "@mpi.normalizeci" {
  run @mpi.normalizeci
  [[ $status -eq 0 ]]
  [[ -n $NCI ]]
}
