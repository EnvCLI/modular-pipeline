#!/usr/bin/env bash
set -euo pipefail

# Runs BATS execute bash script test files
#
# Environment:
#   TEST_DIR: the directory that contains the bats test files, will be searched in recursively.
#
# The output follows the TAP format and can easily be parsed and processed.
function main()
{
  # configuration
  TEST_DIR=${TEST_DIR:-tests}

  # bats is needed on the host, because tests depend on host tools (docker, envcli)
  if ! command -v bats > /dev/null; then
    # need to install bats
    tmpRepoDir=$(mktemp --directory)
    # - linux
    if [ "$HOST_OS" == "linux" ]; then
      @mpi.log_message "INFO" "installing bats for linux on the host to [/usr/local]"
      git clone https://github.com/bats-core/bats-core.git "$tmpRepoDir"
      sudo $tmpRepoDir/install.sh /usr/local
    fi
    # - windows
    if [ "$HOST_OS" == "windows" ]; then
      @mpi.log_message "INFO" "installing bats for windows on the host to [$HOME]"
      git clone https://github.com/bats-core/bats-core.git "$tmpRepoDir"
      sudo $tmpRepoDir/install.sh $HOME
    fi
  else
    @mpi.log_message "DEBUG" "bats already present on host, not doing anything."
  fi

  # use parallel for test execution if available
  if command -v parallel > /dev/null; then
    @mpi.run_command bats --tap --jobs 4 --recursive $TEST_DIR
  else
    @mpi.run_command bats --tap --recursive $TEST_DIR
  fi
}

# entrypoint
main "$@"
