#!/usr/bin/env bash
set -euo pipefail

# Main Function
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # get dependencies
  # - legacy
  if test -f requirements.txt; then
    @mpi.log_message "WARN" "The recommended way to manage your dependency is pipenv!"
    @mpi.container_command pip install -r requirements.txt
  fi
  # - modern
  if test -f requirements.txt; then
    @mpi.container_command pipenv install
  fi

  # compile .py files
  @mpi.log_message "INFO" "Compiling all python source files ..."
  @mpi.container_command python -m compileall .
}

# entrypoint
main "$@"
