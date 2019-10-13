#!/usr/bin/env bash
set -euo pipefail

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

# Public: Load variables from file (or keep current env if set)
#
# This will load environment variables form a file.
# Behavior:
#  Will overwrite any existing variables.
#  If you expect a variable to be provided by the ci system, you can set the value to `session.environment` to require it.
#
# $1 - File Path
#
# Examples
#
#   @mpi.load_env_from_file ".ci/env"
#
# Returns the exit code of the last command executed or 0 otherwise
@mpi.load_env_from_file() {
  declare fileName="${1}"
  @mpi.log_message "TRACE" "@mpi.load_env_from_file : $fileName"
  @mpi.log_message "DEBUG" "loading environment from ${fileName}"
  MPI_DEPLOY_VARS=${MPI_DEPLOY_VARS:-}

  # iterator over all lines
  while read -r line ; do
    # valid lines need to at least include a =
    if [[ ! $line =~ .*"=".* ]]; then
      @mpi.log_message "WARN" "ignoring line [$line], not a valid env assignment!"
      continue
    fi

    IFS== read -r key val <<< $(echo "$line" | tr -d '\r' | tr -d '\n')
    val=${val%\"}; val=${val#\"};
    key=${key#export }; key=${key#\"};
    MPI_DEPLOY_VARS="${MPI_DEPLOY_VARS} ${key}"
    evalStatement=$(echo "export $key=\"${val//\"/\\\"}\"")

    # allow overwriting if var is loaded by file, do not set if var was already present on the host (for ci provided vars that have priority)
    if [ $val == "session.environment" ]; then
      @mpi.log_message "DEBUG" "will set value from current environment, this will fail if the variable is not set!"
      set +u
      if [ -n "${!key+set}" ]; then
        @mpi.run_command export "ORIGINOF_${key}"="session.environment"
      else
        @mpi.log_message "ERROR" "supposed to take value [$key] from host environment, but is not set!"
        exit 1
      fi
      set -u
    else
      @mpi.log_message "DEBUG" "setting var [$key]=[$val]"
      @mpi.run_command eval "$evalStatement"
      @mpi.run_command export "ORIGINOF_${key}"="file:$fileName"
    fi
  done < <(grep -v '^#' ${fileName} | sort)

  export MPI_DEPLOY_VARS
}
