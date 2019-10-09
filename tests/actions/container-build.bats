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
@test "@mpi.action.container-build" {
  cd "${SAMPLE_DIR}/container/docker"
  mkdir -p dist tmp
  run @mpi action container-build
  [[ $status -eq 0 ]]
}
