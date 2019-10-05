#!/usr/bin/env bats

# Setup
setup() {
  . ${BATS_CWD}/src/mpi-core.bash
  @mpi.test_setup
}

# Teardown
teardown() {
  @mpi.test_teardown
  rm -rf "$(realpath $ARTIFACT_DIR)"
  rm -rf "$(realpath $TMP_DIR)"
}

# Test Cases
@test "@mpi.action.go-test" {
  cd "${SAMPLE_DIR}/golang"
  run @mpi action go-test
  [[ $status -eq 0 ]]
}