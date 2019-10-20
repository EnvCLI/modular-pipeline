#!/usr/bin/env bash
set -euo pipefail

# Print help
#
# Returns the exit code of the last command executed or 0 otherwise.
print_help()
{
	printf '%s\n' "Changelog Generator"
	printf '\t%s\n' "--ref: git reference to generate the changelog for"
	printf '\t%s\n' "--output: output file for the generated changelog"
	printf '\t%s\n' "-h, --help: Prints help"
}

# Main Function
#
# Environment:
#   *none*
#
# Returns the exit code of the last command executed or 0 otherwise.
main()
{
  # parse arguments
  # - default values
  CHANGELOG_REF="${CHANGELOG_REF:-v0.0.1}"
  CHANGELOG_OUTPUT_FILE="${CHANGELOG_OUTPUT_FILE:-$TMP_DIR/changelog.md}"
  # - parse
  while [ "${1:-}" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
      -h | --help)
        print_help
        exit
        ;;
      --ref)
        CHANGELOG_REF=$VALUE
        ;;
      --output)
        CHANGELOG_OUTPUT_FILE=$VALUE
        ;;
      *)
        echo "ERROR: unknown parameter \"$PARAM\""
        print_help
        exit 1
        ;;
    esac
    shift
  done

  # generate changelog
  @mpi.container_command git-chglog --config "$MPI_RESOURCE_PATH/changelog/publish-release-markdown.yml" --output "$CHANGELOG_OUTPUT_FILE" --no-emoji "$CHANGELOG_REF"
}

# entrypoint
main "$@"
