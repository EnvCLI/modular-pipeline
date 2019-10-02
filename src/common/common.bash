#!/usr/bin/env bash

# global variables
MPI_RESOURCES_BRANCH=${MPI_RESOURCES_BRANCH:-master}
MPI_RESOURCES_MIRROR=${MPI_RESOURCES_MIRROR:-https://raw.githubusercontent.com/EnvCLI/modular-pipeline/$MPI_RESOURCES_BRANCH/resources}

# common
MPI_COMMON_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$MPI_COMMON_PATH/os.bash"
source "$MPI_COMMON_PATH/logging.bash"
source "$MPI_COMMON_PATH/hooks.bash"
source "$MPI_COMMON_PATH/stacktrace.bash"
source "$MPI_COMMON_PATH/scripts.bash"
source "$MPI_COMMON_PATH/commands.bash"
source "$MPI_COMMON_PATH/action.bash"
source "$MPI_COMMON_PATH/test.bash"
