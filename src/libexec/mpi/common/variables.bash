#!/usr/bin/env bash

# Public: Gets the filepath for the specified variable or overwrites it with a default
#
# Will set the following properties:
#  VARNAME: Full path to the file
#  VARNAME_DIR: Directory of the file
#  VARNAME_FILENAME: Filename without path
#
# $1 - File Path
#
# Examples
#
#   @mpi.get_filepath_or_default "./Dockerfile"
#
# Returns the exit code of the last command executed or 0 otherwise
@mpi.get_filepath_or_default() {
  declare varname="${1}" defaultFileName="${2}" varnameRes="${1}_RESOURCE" varnameUrl="${1}_URL"
  @mpi.log_message "TRACE" "@mpi.get_filepath_or_default : $varname : $defaultFileName"

  # configuration
  local filpeath=${!varname:-}
  local filpeathFromResources=${!varnameRes:-}
  local filpeathFromUrl=${!varnameUrl:-}
  @mpi.run_command export "${varname}=$defaultFileName"

  # check if file exists
  if ! test -f "$filpeath"; then
    @mpi.log_message "DEBUG" "file [$filpeath] not found locally."

    if [ -n "$filpeathFromResources" ]; then
      @mpi.log_message "INFO" "taking [$defaultFileName] from resources [$MPI_RESOURCE_PATH/$filpeathFromResources]!"
      cp "$MPI_RESOURCE_PATH/$filpeathFromResources" "${TMP_DIR}/${defaultFileName}"
      export "${varname}=${TMP_DIR}/${defaultFileName}"
    elif [ -n "$filpeathFromUrl" ]; then
      @mpi.log_message "INFO" "taking [$defaultFileName] from remote url [$MPI_RESOURCE_PATH/$filpeathFromResources]!"
      curl -L -s -o "${TMP_DIR}/${defaultFileName}" "$filpeathFromUrl"
      export "${varname}=${TMP_DIR}/${defaultFileName}"
    else
      @mpi.log_message "ERROR" "file [$defaultFileName] not present and no default available!"
      return 1
    fi
  fi

  @mpi.run_command export "${varname}_PATH=$(dirname $(realpath "$defaultFileName"))"
  @mpi.run_command export "${varname}_FILENAME=$(basename $(realpath "$defaultFileName"))"
}
