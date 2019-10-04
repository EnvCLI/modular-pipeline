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
@test "@mpi.action.java-test - gradle" {
  cd "${SAMPLE_DIR}/java/gradle"
  run @mpi action java-test
  [[ $status -eq 0 ]]
}

@test "@mpi.action.java-test - maven" {
  cd "${SAMPLE_DIR}/java/maven"
  run @mpi action java-test
  [[ $status -eq 0 ]]
}
