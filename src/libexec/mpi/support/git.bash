#!/usr/bin/env bash
set -euo pipefail

# Public: Diff commits and get changed files based on criteria
#
# This will set BUILD_SYSTEM to a build system or unknown of nothing was found.
#
# Examples
#
#   @mpi.git.diff_get_files
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.git.diff_get_files()
{
  declare fromCommit="${1:-HEAD~0}" toCommit="${2:-HEAD~1}" diffFilter="${3:-d}" relativePath="${4:-}" includeFilter="${5:-*.item}" excludeFilter="${6:-^$}"

  diffFileNamesFile=$(mktemp)
  @mpi.run_command git diff --name-only --diff-filter="$diffFilter" --relative="$relativePath" "$toCommit" "$fromCommit" | grep -E "$includeFilter" | grep --invert-match -E "$excludeFilter" > "$diffFileNamesFile"
  mapfile -t < "$diffFileNamesFile"
  rm "$diffFileNamesFile"

  export DIFF_FILES="${MAPFILE[@]}"
}
