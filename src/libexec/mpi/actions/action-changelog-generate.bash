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
  CHANGELOG_CONFIG_FILE="${CHANGELOG_CONFIG_FILE:-$TMP_DIR/changelog/publish-release-markdown.yml}"
  # - parse
  while [ "${1:-}" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
      -h | --help)
        print_help
        exit
        ;;
      --config)
        CHANGELOG_CONFIG_FILE=$VALUE
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

  # copy template file into tmp dir
  cp -R "$MPI_RESOURCE_PATH/changelog" "$TMP_DIR"

  # generate changelog
  @mpi.container_command git-chglog --config "$CHANGELOG_CONFIG_FILE" --output "$CHANGELOG_OUTPUT_FILE" --no-emoji "$CHANGELOG_REF"
}

# entrypoint
main "$@"
