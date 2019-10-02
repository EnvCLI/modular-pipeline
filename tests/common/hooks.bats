#!/usr/bin/env bats

# Setup
setup() {
  . ${BATS_CWD}/src/mpi-core.bash
  @mpi.test_setup
  export MPI_HOOKS_DIR=$(mktemp --directory)
}

# Teardown
teardown() {
  @mpi.test_teardown
  rm -rf $MPI_HOOKS_DIR
  unset MPI_HOOKS_DIR
}

# Test Cases
@test "@mpi.run_hook - hook present" {
  echo "echo \"Hello Hook\"" >> $MPI_HOOKS_DIR/pre_build.sh
  chmod +x $MPI_HOOKS_DIR/pre_build.sh
  run @mpi.run_hook "pre_build"

  [[ $status -eq 0 ]]
  [[ ${lines[0]} == "Hello Hook" ]]
}

@test "@mpi.run_hook - hook not present" {
  run @mpi.run_hook "post_build"

  [[ $status -eq 1 ]]
}
