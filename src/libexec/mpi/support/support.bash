#!/usr/bin/env bash

# common
MPI_SUPPORT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$MPI_SUPPORT_PATH/container.bash"
source "$MPI_SUPPORT_PATH/deploy.bash"
source "$MPI_SUPPORT_PATH/java.bash"
source "$MPI_SUPPORT_PATH/kubernetes.bash"
source "$MPI_SUPPORT_PATH/git.bash"
source "$MPI_SUPPORT_PATH/discord.bash"
source "$MPI_SUPPORT_PATH/rocketchat.bash"
