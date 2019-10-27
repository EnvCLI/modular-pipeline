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
@test "@mpi.action.revealjs-build" {
  cd "${SAMPLE_DIR}/revealjs"
  mkdir -p dist tmp
  run @mpi action revealjs-build
  [[ $status -eq 0 ]]
}
