#!/usr/bin/env bash

# common
MPI_COMMON_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$MPI_COMMON_PATH/os.bash"
source "$MPI_COMMON_PATH/logging.bash"
source "$MPI_COMMON_PATH/hooks.bash"
source "$MPI_COMMON_PATH/stacktrace.bash"
source "$MPI_COMMON_PATH/scripts.bash"
source "$MPI_COMMON_PATH/commands.bash"
source "$MPI_COMMON_PATH/variables.bash"
source "$MPI_COMMON_PATH/test.bash"
