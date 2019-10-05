#!/usr/bin/env bash

# common
MPI_COMMON_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$MPI_COMMON_PATH/../common/common.bash"

# pipeline
MPI_PIPELINE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$MPI_PIPELINE_PATH/prepare.bash"
