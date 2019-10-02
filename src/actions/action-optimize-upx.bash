#!/usr/bin/env bash
set -euo pipefail

# Compress binary files with the Ultimate Packer for eXecutables
#
# This can take a lot of time depending on the compression method and artifact files.
#
# Environment:
#  DEBUG: Can be set to true to enable debugging
#  ARTIFACT_DIR: All files from this directory will be published on bintray (default: dist)
#  ARTIFACT_FILTER: a glob filter to only run this for specific artifacts (default: *)
#  UPX_ARGS: Defaults to `--brute`, use `--best --ultra-brute` for best compression.
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # configuration
  ARTIFACT_DIR=${ARTIFACT_DIR:-dist}
  ARTIFACT_FILTER=${ARTIFACT_FILTER:-*}
  UPX_ARGS=${UPX_ARGS:---brute}

  # execute
  @mpi.log_message "INFO" "Compressing artifacts in directory [$ARTIFACT_DIR] with file filter [$ARTIFACT_FILTER]"
  for file in $ARTIFACT_DIR/$ARTIFACT_FILTER
  do
    if [ -f "$file" ]; then
      # compress file
      @mpi.log_message "INFO" "Compressing file [$file]"
      @mpi.container_command upx $UPX_ARGS "$file"
    else
      @mpi.log_message "WARN" "No files found in [$ARTIFACT_DIR] that match filter [$ARTIFACT_FILTER]!"
      continue
    fi
  done
}

# entrypoint
main "$@"
