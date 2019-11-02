#!/usr/bin/env bash

# Public: Detect execution environment
#
# This will set HOST_OS and HOST_ARCH based on the current environment
#
# Examples
#
#   @mpi.detect_environment
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.detect_environment() {
  # detect os
  case "$(uname -s)" in
    Linux*)     HOST_OS=linux;;
    Darwin*)    HOST_OS=darwin;;
    CYGWIN*)    HOST_OS=windows;;
    MINGW*)     HOST_OS=windows;;
    *)          HOST_OS="UNKNOWN:$(uname -s)"
  esac
  export HOST_OS

  # detect arch
  case "$(uname -m)" in
    x86_64*)    HOST_ARCH=amd64;;
    i386*)      HOST_ARCH=386;;
    *)          HOST_ARCH="UNKNOWN:$(uname -m)"
  esac
  export HOST_ARCH
}

# Public: Removes a file if it is present, does nothing otherwise
#
# Examples
#
#   @mpi.file.safe_remove "file.txt"
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.file.safe_remove() {
  declare file="${1}"

  # check if file is present and remove
  if [ -f "$file" ]; then
    rm "$file"
  fi
}
