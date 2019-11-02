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
  local filepath=${!varname:-}
  local filepathFromResources=${!varnameRes:-}
  local filepathFromUrl=${!varnameUrl:-}
  @mpi.run_command export "${varname}"="$defaultFileName"

  # check if file exists
  if ! test -f "$filepath"; then
    @mpi.log_message "DEBUG" "file [$filepath] not found locally."

    if [ -n "$filepathFromResources" ]; then
      @mpi.log_message "INFO" "taking [$defaultFileName] from resources [$MPI_RESOURCE_PATH/$filepathFromResources]!"
      cp "$MPI_RESOURCE_PATH/$filepathFromResources" "${TMP_DIR}/${defaultFileName}"
      export "${varname}"="${TMP_DIR}/${defaultFileName}"
    elif [ -n "$filepathFromUrl" ]; then
      @mpi.log_message "INFO" "taking [$defaultFileName] from remote url [$MPI_RESOURCE_PATH/$filepathFromResources]!"
      curl -L -s -o "${TMP_DIR}/${defaultFileName}" "$filepathFromUrl"
      export "${varname}"="${TMP_DIR}/${defaultFileName}"
    else
      @mpi.log_message "ERROR" "file [$defaultFileName] not present and no default available!"
      return 1
    fi
  fi

  @mpi.run_command export "${varname}_PATH=$(dirname $(realpath "${!varname}"))"
  @mpi.run_command export "${varname}_FILENAME=$(basename $(realpath "${!varname}"))"
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
  varFile=$(mktemp)
  grep -v '^#' ${fileName} | grep -v '^[[:space:]]*$' | sort > "$varFile"
  while read -r line; do
    # valid lines need to at least include a =
    if [[ ! $line =~ .*"=".* ]]; then
      @mpi.log_message "WARN" "ignoring line [$line], not a valid env assignment!"
      continue
    fi

    IFS== read -r key val <<< $(echo "$line" | tr -d '\r' | tr -d '\n')
    # escape val for eval statement
    val=${val%\"}; val=${val#\"}; escapedVal=$val;
    key=${key#export }; key=${key#\"};
    MPI_DEPLOY_VARS="${MPI_DEPLOY_VARS} ${key}"

    # allow overwriting if var is loaded by file, do not set if var was already present on the host (for ci provided vars that have priority)
    if [ "$val" == "session.environment" ]; then
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
      @mpi.run_command export "${key}=$val"
      @mpi.run_command export "ORIGINOF_${key}=file:$fileName"
    fi
  done < "$varFile"
  rm "$varFile"

  export MPI_DEPLOY_VARS
}

# Public: Substitues environment variables in a file
#
# $1 - File Path
#
# Examples
#
#   @mpi.substitute_environment_in_file "fileName"
#
# Returns the exit code of the last command executed or 0 otherwise
@mpi.substitute_environment_in_file() {
  declare fileName="${1}"
  @mpi.log_message "DEBUG" "replacing environment variables present in $fileName"

  tempFile=$(mktemp)

  envsubst < "${fileName}" > "${tempFile}"
  local newContent=$(cat "$tempFile")
  @mpi.log_message "TRACE" "new file content: $newContent"
  cp "${tempFile}" "${fileName}"
  rm "${tempFile}"
}
