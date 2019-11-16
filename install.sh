#! /usr/bin/env bash

###
# This script installs the modular pipeline itself
###

set -e
echo "Installing modular pipeline ..."
gitRepo=${gitRepo:-https://github.com/EnvCLI/modular-pipeline.git}

# preq: envcli
if ! [ -x "$(command -v envcli)" ]; then
  echo "ERROR: please install envcli on your host machine!"
  exit 1
fi

# arguments
MPI_ROOT="${0%/*}"
PATH_PREFIX="$1"

if [[ -z "$PATH_PREFIX" ]]; then
  printf '%s\n' \
    "usage: $0 <prefix>" \
    "  e.g. $0 /usr/local" >&2
  exit 1
fi

# get files if not present locally
if [ -d "$MPI_ROOT/src/libexec/mpi" ]; then
  echo "Installing using local files ..."
else
  if ! [ -x "$(command -v git)" ]; then
    echo "ERROR: please install git on your host machine!"
    exit 1
  fi

  echo "Cloning git repository ..."
  tmpDir=$(mktemp -d)
  git clone "$gitRepo" --single-branch "$tmpDir"
  MPI_ROOT=$(realpath $tmpDir)
fi

# installation
cp --recursive --preserve=all "$MPI_ROOT/src/." "$PATH_PREFIX/"
chmod -R 755 "$PATH_PREFIX/bin/mpi"
chmod -R 755 "$PATH_PREFIX/libexec/mpi"

echo "Installed MPI to $PATH_PREFIX/bin/mpi"
