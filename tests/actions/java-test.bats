#!/usr/bin/env bats

# Setup
setup() {
  . ${BATS_CWD}/src/libexec/mpi/mpi-core.bash
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
  mkdir -p dist tmp
  run @mpi action java-test
  [[ $status -eq 0 ]]
}

@test "@mpi.action.java-test - maven" {
  cd "${SAMPLE_DIR}/java/maven"
  mkdir -p dist tmp
  run @mpi action java-test
  [[ $status -eq 0 ]]
}
